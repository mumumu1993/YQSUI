YQSUI — 指定角圆角与相关视图扩展 (YQSUIRoundedCorner.swift)

简介

`YQSUIRoundedCorner.swift` 提供了一个可对视图的特定角（例如仅顶端两个角或仅左侧两个角）进行圆角裁剪的 `Shape` 实现 `YQSUIRoundedCorner`，并附带一组方便的 `View` 扩展方法来应用圆角、裁剪、以及为指定角的圆角形状添加描边（边框）。

该文件适用于在 SwiftUI 中需要只对部分角进行圆角处理的场景（SwiftUI 原生的 `RoundedRectangle` 只能对所有角生效）。

可用性

- 依赖: SwiftUI、UIKit 的 `UIRectCorner` 与 `UIBezierPath`（用于创建带指定圆角的 `CGPath`）。
- 可用平台: iOS 13.0 及以上（文件中添加了 `@available(iOS 13.0, *)` 标注）。

API 概览

- public struct YQSUIRoundedCorner: Shape
  - init(radius: CGFloat, corners: UIRectCorner)
    - 通过指定半径与 `UIRectCorner`（例如 `.topLeft`、`.topRight` 或组合）创建一个 `Shape`，用于 `clipShape` 或 `overlay`。
  - func path(in rect: CGRect) -> Path
    - 使用 `UIBezierPath(roundedRect:byRoundingCorners:cornerRadii:)` 构造 `UIBezierPath`，并以其 `cgPath` 转换为 SwiftUI `Path` 返回。

- public enum YQSUIRectCorners
  - 提供了常用的 `UIRectCorner` 组合快捷值：
    - `allCorners`、`topCorners`、`bottomCorners`、`leftCorners`、`rightCorners`

- public extension View
  - func yqsUICornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View
    - 仅对 `corners` 中指定的角应用圆角（通过 `clipShape(YQSUIRoundedCorner(...))` 实现）。
  - func yqsUIClipRoundedRect(_ radius: CGFloat, corners: UIRectCorner) -> some View
    - 等价于 `yqsUICornerRadius`，语义更偏“裁剪”。
  - func yqsUIRoundedBorder(_ color: Color, lineWidth: CGFloat = 1, cornerRadius: CGFloat, corners: UIRectCorner) -> some View
    - 给指定角的圆角形状添加边框（使用 `overlay` + `stroke`）。
  - func yqsUIRectContentShape() -> some View
    - 将交互区域恢复为矩形（`contentShape(Rectangle())`），适用于想要视觉裁剪但保留矩形触摸区域的场景。
  - 另外提供了多个便捷重载：
    - `yqsUICornerRadius(_ radius: CGFloat)`（对所有角）
    - `yqsUITopCornerRadius(_ radius: CGFloat)`（仅顶部两个角）
    - `yqsUIBottomCornerRadius(_ radius: CGFloat)`（仅底部两个角）
    - `yqsUIRoundedBorder(_ color: Color, lineWidth: CGFloat = 1, cornerRadius: CGFloat)`（对所有角）
    - `yqsUITopRoundedBorder(...)`、`yqsUIBottomRoundedBorder(...)`（针对顶部/底部两个角）

使用示例（Swift）

```swift
import SwiftUI

// 基本裁剪：仅对顶部两个角应用圆角
Text("Hello")
    .padding(12)
    .background(Color.white)
    .yqsUITopCornerRadius(12)

// 带边框的部分角圆角
Rectangle()
    .fill(Color.clear)
    .frame(height: 50)
    .yqsUIRoundedBorder(.blue, lineWidth: 2, cornerRadius: 12, corners: [.topLeft, .topRight])

// 在卡片中：视觉圆角，但触摸区域为矩形
VStack {
    Text("Tap me")
}
.padding()
.background(Color(white: 0.95))
.yqsUICornerRadius(10)
.yqsUIRectContentShape()

// 直接使用 Shape：作为自定义形状使用
ZStack {
    YQSUIRoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight])
        .fill(Color.green)
        .frame(height: 80)
}
```

注意事项

- `YQSUIRoundedCorner` 使用了 `UIBezierPath` 与 `UIRectCorner`，这两个 API 属于 UIKit；因此该实现以 iOS 为目标平台（macOS 平台需要替换相应的路径构造实现）。
- `yqsUIRectContentShape()` 在你对视图裁剪后希望保留原始矩形的可点按区域时非常有用，例如在 `List` 的单元格或卡片中；如果不调用该方法，触摸区域会和裁剪形状一致（圆角内）。
- 当在极窄或极小的矩形上使用非常大的半径时，视觉效果由系统的 `UIBezierPath` 行为决定；在某些极端尺寸下，圆角会被限制以避免重叠。
- `UIRectCorner` 使用位掩码组合，注意传入参数的正确性（例如 `.topLeft.union(.topRight)` 或直接写 `[.topLeft, .topRight]`）。

贡献与许可证

欢迎提交 issue 或 PR，对该文件进行修复或增强（例如：
- 为 macOS 添加跨平台实现（使用 `Path` 的直接构造）
- 支持动画友好的圆角过渡
- 提供基于 `CornerRadiusStyle` 的不同圆角样式）。

作者: yumumu
文件: YQSUIRoundedCorner.swift
