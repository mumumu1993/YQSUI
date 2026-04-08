YQSUI — 提示 / 吐司（Toast）组件 (YQSUITips.swift)

简介

`YQSUITips.swift` 提供了一套轻量的 Toast（短暂提示）实现，包含：
- 一个数据模型 `YQSUIToast`，用于描述提示文本、样式、显示时长与位置；
- 一个 SwiftUI 可观测管理器 `YQSUIToastManager`（支持数据驱动显示/隐藏与自动计时）；
- 一个 SwiftUI 视图 `YQSUIToastView` 与 `YQSUIToastModifier`，可通过 `.yqsUIToast(_:)` 将吐司层挂载到任意视图上；
- UIKit 全局呈现实现（`showInUIKit`）用于在混合或纯 UIKit 应用中以 overlay 方式展示吐司；
- 一个 Objective-C friendly 桥接类 `YQSUIToastBridge`，便于 Objective-C 调用常用方法。

该实现目标是提供跨 SwiftUI / UIKit 的统一短时提示方案，便于在不同 UI 栈中复用相同的样式与调用方式。

可用性

- 依赖：SwiftUI + UIKit（UIKit 用于全局 overlay 的实现）。
- 平台：iOS（使用了 `UIApplication` / `UIWindow` / `UIView` 等 UIKit API）。
- 最低部署：与项目其它文件一致（通常 iOS 13+ 支持 SwiftUI）。

API 概览

- enum YQSUIToastStyle: 吐司样式
  - cases: `.info`, `.success`, `.warning`, `.error`
  - 提供颜色（`background` / `foreground`）与 SF Symbol 图标名 (`icon`) 的映射，方便统一样式。

- enum YQSUIToastPosition: 位置
  - cases: `.top`, `.center`, `.bottom`

- struct YQSUIToast: Identifiable & Equatable
  - 属性: `message`, `style`, `duration`, `position`
  - 用于描述一次吐司要显示的完整信息。

- class YQSUIToastManager: ObservableObject
  - 单例: `YQSUIToastManager.shared`
  - 发布属性: `@Published private(set) var toast: YQSUIToast?`（供 SwiftUI 层监听）
  - 方法:
    - `show(_:style:duration:position:)` —— 在 SwiftUI 路径显示一个吐司（数据驱动）
    - `hide()` —— 隐藏当前吐司
    - `static func showGlobal(_:style:duration:position:)` —— 全局入口，内部会根据是否为 UIKit 模式决定走 UIKit overlay 或 shared manager
    - `@objc static func showGlobal(_:style:duration:position:)` —— ObjC-friendly overload（接受 Int 枚举值）
    - `@objc static func initializeForUIKit()` —— 切换到 UIKit 演示模式（会让 `showGlobal` 使用 overlay），可在 AppDelegate 中调用。

- SwiftUI 视图层
  - `private struct YQSUIToastView: View` —— 吐司的视觉实现（包含可选的 SF Symbol 图标与多行文本），并设置了 `accessibilityIdentifier("YQSUIToastView")`。
  - `private struct YQSUIToastModifier: ViewModifier` —— 将吐司层以 `ZStack` overlay 的方式挂载在任意视图上，并支持不同位置的过渡动画。
  - `public extension View { func yqsUIToast(_ manager: YQSUIToastManager) -> some View }` —— 便捷修饰器，传入 manager 后即可在视图树中展示吐司。

- Objective-C 桥接
  - `@objcMembers public class YQSUIToastBridge: NSObject` —— 提供若干静态方法供 ObjC 使用：
    - `show(_:style:duration:position:)`、`hide()`、以及 `showInfo` / `showSuccess` / `showWarning` / `showError` 的便捷方法。

使用示例（SwiftUI）

// 在 App 或页面根视图中挂载吐司层
import SwiftUI

struct ContentView: View {
    // 推荐使用单例以便在任意地方通过 YQSUIToastManager.shared 调用
    private let toastManager = YQSUIToastManager.shared

    var body: some View {
        NavigationView {
            VStack {
                Button("Show Success Toast") {
                    toastManager.show("保存成功", style: .success, duration: 2.0, position: .bottom)
                }
            }
            .navigationTitle("Demo")
        }
        .yqsUIToast(toastManager) // 将吐司层挂载在最外层
    }
}

// 也可在任意视图中直接调用 manager.show(...) 展示

使用示例（UIKit 全局）

// 在 AppDelegate 或应用启动时开启 UIKit 模式（可选）
YQSUIToastManager.initializeForUIKit()

// 任意 Objective-C/Swift 代码中使用全局方法
YQSUIToastManager.showGlobal("网络错误，请稍后重试", style: .error, duration: 2.0, position: .top)

// 或通过 ObjC 桥接类
YQSUIToastBridge.showError("请求失败")

注意事项与实现细节

- UIKit overlay 实现细节：
  - `showInUIKit` 会在主窗口上创建一个 `UIView` 作为吐司容器，使用 Auto Layout 约束定位（支持 safeArea）并添加进出场动画；
  - 为避免重复堆叠，方法会先移除已有 `toastView` 再添加新的视图；
  - 点击吐司会触发隐藏（内部添加了 UITapGestureRecognizer）。

- 线程与主队列：
  - 所有显示/隐藏操作均切换到主线程执行（`DispatchQueue.main.async`），以避免 UI 线程问题。

- 单例与 UIKit 模式：
  - `YQSUIToastManager.shared` 提供 SwiftUI 路径的单例；`showGlobal` 可选择使用 UIKit overlay（当调用 `initializeForUIKit()` 后）或通过单例发布数据到 SwiftUI 层。

- 可访问性与测试：
  - 吐司视图设置了 `accessibilityIdentifier` 为 `YQSUIToastView`，测试时可用该标识符查找元素并断言其存在/消失。

测试建议

- UI Test（XCUITest）:
  - 在 UI 测试中优先使用 `accessibilityIdentifier` 定位吐司视图，例如：`app.otherElements["YQSUIToastView"]`；注意如果应用使用了 UIKit 全局 overlay，吐司是以 `UIView` 添加到 window 上，XCUITest 仍能通过 accessibility 进行识别。

- 单元测试:
  - 对于纯逻辑部分（如 `YQSUIToast` 的 Equatable/初始化），可编写常规单元测试；对于 UI 展示建议使用 UI tests 或在 SwiftUI Preview 中手动验证动画与位置。

贡献与许可证

欢迎提交 Issue 或 PR 来增强吐司功能（例如：支持自定义样式、动画、可配置的最大宽度、交互队列、以及更细粒度的多窗口/Scene 支持）。

作者

- yumumu

相关文件

- `Sources/YQSUI/YQSUITips.swift` — 源码实现
- `docs/YQSUI/YQSUITips_ReadMe.md` — 本文档
