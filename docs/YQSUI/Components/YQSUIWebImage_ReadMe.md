YQSUI — 轻量 Web Image（YQSUIWebImage.swift）

简介

`YQSUIWebImage.swift` 提供了一个轻量级的 SwiftUI 网络图片组件 `YQSUIWebImage`，支持：
- 占位图与错误图显示；
- 自定义请求头（例如 `Referer`）；
- 可配置的内存与磁盘缓存（支持内存仅、磁盘仅或两者）；
- SwiftUI 风格的可定制内容闭包（允许在加载后的 `Image` 上添加任意修饰器）；
- UIKit 模式下的磁盘缓存与全局可用性（文件缓存目录、过期/容量淘汰）。

目标

为不想引入大体积第三方库时提供一个功能完整且简单可扩展的网络图片加载与缓存方案，适合在 SwiftUI 视图中以最小依赖展示远程图片。

可用性

- 依赖: SwiftUI、UIKit、CryptoKit（用于 URL 的 SHA256 命名磁盘缓存文件）。
- 平台: iOS（使用 UIKit 的 UIImage、FileManager 与 UIApplication 缓存目录）。
- 最低部署: 与项目的 SwiftUI 支持版本一致（通常 iOS 13+）。

API 概览

- `public struct YQSUIWebImage<Content: View>: View`
  - 初始化参数：
    - `url: URL?` — 远程资源 URL（可为 nil，用于占位展示）。
    - `placeholder: Image?` — 加载中显示的占位图（默认系统图）。
    - `errorImage: Image?` — 加载失败时显示的错误图（默认系统图）。
    - `headers: [String: String]?` — 可选请求头（默认包含 `Referer: https://www.zdyai.com`，可通过 headers 覆盖/扩展）。
    - `contentMode: ContentMode` — `.fill` 或 `.fit`，控制加载后图像的缩放行为。
    - `cacheConfiguration: YQSUIWebImageCacheConfiguration` — 缓存大小配置（内存、磁盘）。
    - `@ViewBuilder content: (Image) -> Content` — 加载成功后的 `Image` 修饰闭包，用于在外部添加 `.resizable()`、`.cornerRadius()` 等。
  - 行为：在 `body` 中根据 `ImageLoader` 的状态显示已加载图片、占位图或错误图；在 `onAppear` 时触发加载（`loadIfNeeded()`），在 `onDisappear` 时取消任务。

- `public struct YQSUIWebImageCacheConfiguration: Equatable`
  - 用于指定 `memoryCapacity` 与 `diskCapacity`（以字节为单位）。
  - 提供静态工厂：`.default`、`.memoryOnly`、`.diskOnly`。

- `ImageLoader`（私有，`ObservableObject`）
  - 发布属性：`@Published var image: UIImage?`、`@Published var isLoading: Bool`。
  - 内部缓存：
    - 静态 `NSCache<NSURL, UIImage>` 用作内存缓存（`totalCostLimit` 可根据配置调整）。
    - 静态 `DiskImageCache` 用作磁盘缓存（异步 IO 队列，基于 SHA256(url.absoluteString) 生成文件名）。
  - 加载流程：
    1. 先查内存缓存；
    2. 若启用磁盘缓存则异步查磁盘；
    3. 否则或磁盘未命中则发起 `URLSession` 请求，带上 headers；
    4. 成功后在主队列写入内存与磁盘缓存并发布 `image`。
  - 提供取消 (`cancel`) 与配置更新（静态 `configureCachesIfNeeded`) 逻辑。

- `DiskImageCache`（私有）
  - 在 `Caches` 目录下管理 `YQSUIWebImage` 子目录；写入文件时会更新文件修改时间作为 LRU 的依据；
  - `store(_:for:)`、`image(for:completion:)`、`update(maxSize:)`、`clearAll()` 与容量裁剪（`enforceLimitIfNeeded()`）通过后台 `ioQueue` 异步执行；
  - 文件名通过 `SHA256(url.absoluteString)` 生成十六进制字符串，避免非法字符与长度冲突。

- `UIImage` 私有扩展：
  - `yqs_memoryCost`：估算像素占用（以 4 字节/像素为基准），用于 `NSCache` 的 cost。

实现细节与注意事项

- 默认请求头：构造器会以 `Referer: https://www.zdyai.com` 作为基础头部，然后将传入 `headers` 合并（传入键会覆盖默认值）。
- 缓存切换：当 `YQSUIWebImageCacheConfiguration` 被改变（不同内存/磁盘容量）时，`ImageLoader.configureCachesIfNeeded` 会更新内存缓存限制与磁盘缓存的 `maxSize`。
- 磁盘缓存 IO：所有磁盘读写与清理由专用串行 `DispatchQueue` 执行，避免主线程阻塞。
- 数据写入策略：优先使用 PNG (`pngData()`)，若不可用则使用 JPEG（quality 0.9）。
- 线程安全：通过 `NSLock`（`cacheLock`）在更新静态缓存配置时保护并发状态。

异步/错误处理

- 网络请求在 `URLSession.shared.dataTask` 中执行，完成处理在主队列回调并更新 `image` 与 `isLoading`。
- 若请求失败或数据无法解码为 `UIImage`，`image` 被设置为 `nil`（组件会显示 `errorImage`）。

使用示例（SwiftUI）

```swift
import SwiftUI

YQSUIWebImage(url: URL(string: "https://picsum.photos/200/200"), placeholder: Image(systemName: "photo"), errorImage: Image(systemName: "exclamationmark.triangle"), contentMode: .fit) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .cornerRadius(8)
}
.frame(width: 160, height: 160)

// 占位示例（url 为 nil）
YQSUIWebImage(url: nil, placeholder: Image(systemName: "photo"), errorImage: Image(systemName: "exclamationmark.triangle")) { image in
    image
}

// 指定自定义请求头（例如 Referer）
YQSUIWebImage(url: URL(string: "https://example.com/image.jpg"), headers: ["Referer": "https://www.example.com"]) { image in
    image
}
```

预览与调试

- 文件末尾包含 `#if DEBUG` 的 `PreviewProvider`，展示了几种不同的 URL/占位/内容模式，方便在 Xcode Canvas 中快速查看效果。

测试建议

- 单元测试：
  - 可对 `ImageLoader` 的缓存命中逻辑（内存/磁盘）与 `yqs_memoryCost` 进行单元测试（通过创建临时 URL 与内存图片模拟）。
  - 对 `DiskImageCache.enforceLimitIfNeeded()` 可在临时目录写入若干伪文件并断言删除最旧文件以收敛到 `maxSize`。

- UI / 集成测试：
  - 在 UI tests 中可设置网络拦截或使用内置预览（Preview）作为快速视觉回归；
  - 为图片视图设置 `accessibilityIdentifier`（你可以在上层容器包裹一个带 `.accessibilityIdentifier("YQSUIWebImage_...")` 的 view）以便 XCUITest 定位与断言。

贡献与扩展方向

- 支持进度回调与占位渐变动画（在下载期间显示占位低透明度渐变或骨架屏）；
- 支持请求重试、超时策略与图片解码队列（避免主线程解码大图）；
- 提供 LRU 元数据索引以减少启动时的目录扫描开销；
- 支持 ImageIO 渐进式加载（JPEG/PNG 渐进渲染）。

作者

- yumumu

相关文件

- `Sources/YQSUI/YQSUIWebImage.swift` — 源码实现
- `docs/YQSUI/YQSUIWebImage_ReadMe.md` — 本文档
