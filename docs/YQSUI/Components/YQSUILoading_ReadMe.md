YQSUI — 全局加载 HUD (YQSUILoading.swift)

简介

`YQSUILoading.swift` 是一个提供全局“加载中”遮罩与指示器的 UI 组件。通过单例模式管理器，您可以在应用的任意位置（如网络请求发起时）快速展示和隐藏带有可选提示文字的 HUD。它采用 SwiftUI ViewModifier 实现，非常适合轻量级的状态反馈。

主要能力

- 支持带有可选文字提示的中心 Loading 动画。
- 通过全屏黑色半透明遮罩防止用户在加载期间进行其他交互（防穿透）。
- 通过 `YQSUILoadingManager.shared` 进行全局单例控制。
- 简单的 ViewModifier `.yqs_loading()` 挂载方式。

API 概览

- YQSUILoadingManager: 全局加载状态控制器
  - 属性:
    - @Published public var isShowing: Bool
    - @Published public var title: String?
  - 基本方法:
    - static let shared: 单例实例
    - func show(title: String? = nil): 显示加载动画，可选附带文字。
    - func hide(): 隐藏加载动画。

- SwiftUI 集成:
  - View.yqs_loading() —— 将 Loading 层挂载到视图树的顶层。

使用示例

1) 在 SwiftUI 根视图挂载

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 在根视图挂载一次即可全局使用
                .yqs_loading()
        }
    }
}

2) 业务代码调用

// 某网络请求开始前
YQSUILoadingManager.shared.show(title: "正在加载...")

// 网络请求结束或失败后
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    YQSUILoadingManager.shared.hide()
}

注意事项与建议

- 推荐将 `.yqs_loading()` 挂载在 `App` 层的 `ContentView` 外层，以确保遮罩能够覆盖整个屏幕（包括 NavigationBar 和 TabBar）。
- 为了保证 UI 线程安全，`show` 和 `hide` 方法内部已经自动包裹了 `DispatchQueue.main.async`。

作者: yumumu
文件: YQSUILoading.swift
