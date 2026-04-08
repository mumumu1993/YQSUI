YQSUI — 工具与通用扩展 (YQSUIUtil.swift)

简介

`YQSUIUtil.swift` 提供了一套常用的 UI 与 SwiftUI 辅助工具与扩展，覆盖了尺寸/安全区获取、主窗口与顶层 UIViewController 的查找、本地化便利方法、以及若干 ViewModifier（按压效果、全屏布局）等。目标是为库中 UI 组件提供稳定的运行时支持与便捷的 UI 操作接口，使业务代码更精简、测试更可靠。

可用性

- 依赖：UIKit（用于窗口/控制器查找与 statusBar 管理）和 SwiftUI（用于 ViewModifier/扩展）。
- 平台：iOS（UIWindow / UIApplication API 属于 UIKit，macOS 需另行实现）。
- 最低部署：视库的其他文件而定（建议 iOS 13+ 以支持 SwiftUI 基础）。

API 概览

- struct YQSUIScreen
  - + width: CGFloat — 屏幕宽度（UIScreen.main.bounds.width）
  - + height: CGFloat — 屏幕高度（UIScreen.main.bounds.height）

- struct YQSUIMainWindow
  - + window: UIWindow? — 应用当前主窗口（从 connectedScenes 中选取 keyWindow）

- String extension
  - func yqs_localized(comment: String = "") -> String
    - NSLocalizedString 的简便封装，用于快速在代码中使用本地化字符串键。

- UIApplication extension（实用查询方法）
  - var currentWindow: UIWindow? — 尝试以 foregroundActive 的 scene 找到 keyWindow，回退到 windows 列表中的 keyWindow 或第一个 window。
  - var currentRootViewController: UIViewController? — 通过 `currentWindow` 获取窗口的 rootViewController。
  - var currentTopViewController: UIViewController? — 递归查找最顶层的 view controller（支持 UINavigationController / UITabBarController / presentedViewController）。
  - var currentNavigationController: UINavigationController? — 在 root 或子控制器中查找 UINavigationController。

- struct YQSUISafeArea
  - + top: CGFloat — 当前窗口的顶部安全区 inset（通常为 status bar + notch 区域高度），实现为 `UIApplication.shared.currentWindow?.safeAreaInsets.top ?? 0`。
  - + bottom: CGFloat — 当前窗口的底部安全区 inset（Home Indicator 区域），实现为 `UIApplication.shared.currentWindow?.safeAreaInsets.bottom ?? 0`。

- struct YQSUIPressEffect: ViewModifier
  - 用于给任意 View 添加按下时的背景颜色切换效果（轻触时显示 pressedColor，释放或取消时还原）。
  - 示例用法：`.modifier(YQSUIPressEffect(normalColor: .white, pressedColor: .gray))` 或使用扩展 `yqsUIPressEffect()`。

- View extension
  - func yqsUIPressEffect(normalColor: Color = .clear, pressedColor: Color = .black.opacity(0.3)) -> some View
    - 便捷调用 `YQSUIPressEffect`。
  - func yqsUIFullScreen(alignment: Alignment = .top) -> some View
    - 便捷调用 `YQSUIFullScreenModifier`，忽略安全区并隐藏导航栏（在 iOS 16+ 使用 toolbar API，低版本回退到 navigationBarHidden）。

使用示例（Swift / SwiftUI）

import SwiftUI

// 1) 获取屏幕与安全区
let screenW = YQSUIScreen.width
let screenH = YQSUIScreen.height
let topInset = YQSUISafeArea.top
let bottomInset = YQSUISafeArea.bottom

// 2) 获取当前顶层 ViewController（在需要从 SwiftUI 跳转到 UIKit 或展示系统弹窗时有用）
if let top = UIApplication.shared.currentTopViewController {
    // 在主线程上使用，例如 present 一个 UIKit 控件
    top.present(UIHostingController(rootView: Text("Hello")), animated: true)
}

// 3) 按压效果
Button(action: {
    print("tapped")
}) {
    Text("Tap me")
        .padding()
        .frame(maxWidth: .infinity)
}
.yqsUIPressEffect(normalColor: .white, pressedColor: .gray.opacity(0.3))

// 4) 全屏布局（隐藏导航栏）
VStack {
    Text("Full screen content")
}
.yqsUIFullScreen()

注意事项与边界条件

- UIWindow / UIApplication API：
  - 在多 scene (iPadOS/iOS 多窗口) 环境下，`YQSUIMainWindow.window` 和 `UIApplication.currentWindow` 的实现选择了 `connectedScenes.first` 的策略，这在大多数单窗口 App 中表现良好，但在多 scene 场景下可能未必返回你期望的窗口（例如你想操作当前激活的 scene）。如需严格兼容多 scene，请根据 app 的 sceneSession 或在调用处传入明确的 window/scene 引用。
  - 这些方法假设在主线程调用；跨线程调用可能出现时序或 nil 值问题。建议在主线程上读取 UI 相关属性。

- statusBar / safe area：
  - `YQSUISafeArea.top` 通过当前 window 的 safeAreaInsets.top 获取，在某些 iOS 版本或场景（比如脱离 window scene）返回 0，是预期行为，使用时请做好 0 值兼容。

- 按压手势的实现：
  - `YQSUIPressEffect` 使用两个相同的 DragGesture（为了兼容不同触摸事件序列），会在某些复杂手势组合上产生重复动画触发。如果你遇到冲突手势（例如与拖动/滑动列表的手势），可考虑替换为 `.onLongPressGesture(minimumDuration: 0)` 或自定义 GestureState 以微调交互体验。

- 全屏修饰器：
  - 在 iOS 16 及以上 `YQSUIFullScreenModifier` 使用了 `.toolbar(.hidden, for: .navigationBar)`；在早期系统使用 `.navigationBarHidden(true)`。根据具体导航结构（NavigationStack vs UINavigationController）显示效果可能略有差异。

测试建议

- UI Tests：
  - 如果在 UI 测试中定位控件，推荐为与 `YQSUI` 交互的关键控件设置 `accessibilityIdentifier`（例如："YQSUIDialogBackdrop", "YQSUIDialogCard", "showAlertButton" 等），提高测试鲁棒性。

- 单元测试：
  - 对非 UI 且纯逻辑的工具方法（如格式化、本地化封装）可编写单元测试；对于依赖窗口/scene 的方法，建议在测试用例中以依赖注入或模拟 window/scene 对象方式进行覆盖。

改进与未来工作

- 多 scene 支持：为 `currentWindow` / `currentTopViewController` 增加基于 SceneSession 的查找 API，或提供可注入的 window 提供者。
- macOS 支持：抽象出平台无关的尺寸与安全区工具，并为 macOS 提供替代实现。
- 按压效果优化：改用更轻量的 GestureState 实现，避免双重 DragGesture 引发的动画抖动。

贡献与许可证

欢迎提交 Issue 或 PR 来改进该工具集（例如：改进多 scene 行为、增加更完善的单元/UI 测试样例）。本文件遵循项目根目录中的 LICENSE（如有）。

作者

- yumumu

相关文件

- `Sources/YQSUI/YQSUIUtil.swift` — 源码实现
- `docs/YQSUI/YQSUIUtil_ReadMe.md` — 本文档
