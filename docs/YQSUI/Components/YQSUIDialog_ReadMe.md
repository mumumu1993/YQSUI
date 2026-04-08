YQSUI — 对话框管理与 UIKit 兼容 (YQSUIDialog.swift)

简介

`YQSUIDialog.swift` 是一个轻量且实用的对话框（Dialog）组件集合，目标在 SwiftUI 应用中提供统一且可扩展的提示、确认与自定义弹窗体验，并同时支持在需要时以全局 UIKit 覆盖层的方式呈现。这使得组件既能在纯 SwiftUI 环境中无缝工作，也能被集成到混合（UIKit + SwiftUI）应用中。

主要能力

- 支持三种风格：Alert（单按钮）、Confirm（确认/取消 两按钮）、Custom（任意 SwiftUI 内容）。
- 通过 `YQSUIDialogManager` 以数据驱动方式展示/隐藏对话框，支持动画和背景遮罩。
- 提供一组便捷 API（showAlert / showConfirm / showCustom）简化业务端调用。
- 提供全局 UIKit 兼容演示模式：在 AppDelegate 中启用后可通过 `YQSUIDialogManager.showGlobal(_:)` 在任何时刻以 UIKit overlay 的方式呈现对话框。

API 概览

- YQSUIDialogAction: 标识单个按钮
  - id: UUID
  - title: String
  - role: YQSUIDialogActionRole（.normal / .cancel / .destructive）
  - handler: (() -> Void)? 业务点击回调（不参与 Equatable）

- YQSUIDialog: 对话框数据模型
  - id: UUID
  - title: String?（可选）
  - message: String?（可选）
  - style: YQSUIDialogStyle（.alert / .confirm / .custom）
  - actions: [YQSUIDialogAction]
  - dismissOnBackgroundTap: Bool
  - customContent: (() -> AnyView)?（仅 style == .custom 时使用，不参与 Equatable）

- YQSUIDialogManager: 对话框控制器
  - 属性:
    - @Published private(set) var dialog: YQSUIDialog? —— 用于 SwiftUI 层的绑定
  - 基本方法:
    - show(_ dialog: YQSUIDialog)
    - hide()
  - 便捷方法:
    - showAlert(title:message:buttonTitle:dismissOnBackgroundTap:onTap:)
    - showConfirm(title:message:confirmTitle:cancelTitle:dismissOnBackgroundTap:onConfirm:onCancel:)
    - showCustom(dismissOnBackgroundTap:content:)
    - showCustom<Content: View>(dismissOnBackgroundTap:@ViewBuilder content:)
  - UIKit 兼容性 (静态 API):
    - initializeForUIKit() —— 在 AppDelegate 中调用以启用 UIKit 模式
    - static func showGlobal(_ dialog: YQSUIDialog)
    - static func hideGlobal()
    - ObjC-friendly static func showGlobal(_ title: String?, message: String?, style: Int, dismissOnBackgroundTap: Bool)

- SwiftUI 集成:
  - View.yqsUIDialog(_ manager: YQSUIDialogManager) —— 将对话框管理器挂载到视图树上
  - YQSUIDialogDismissButton —— 自定义内容内部可调用的关闭按钮（使用 environment 注入）
  - yqsUIDialogDismissAction(_:) —— 在托管自定义内容时注入关闭实现

实现细节与可用性

- 目标平台: iOS（使用了 UIKit API 以实现 UIKit overlay 以及 `UIHostingController` 宿主）。
- 动画: 在 SwiftUI 路径中使用了 spring 动画；UIKit overlay 使用 UIView 动画。
- 可访问性: 对关键元素设置了 identifier（例如 `YQSUIDialogBackdrop`、`YQSUIDialogCard`、`YQSUIDialogAction_<UUID>`），便于 UI 测试与辅助功能定位。

使用示例

1) 在 SwiftUI 中（全局/局部挂载）

import SwiftUI

struct ContentView: View {
    @StateObject private var dialogManager = YQSUIDialogManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Show Alert") {
                    dialogManager.showAlert(title: "提示", message: "这是一个 Alert")
                }

                Button("Show Confirm") {
                    dialogManager.showConfirm(title: "确认", message: "是否继续？", onConfirm: {
                        print("confirmed")
                    }, onCancel: {
                        print("cancelled")
                    })
                }

                Button("Show Custom") {
                    dialogManager.showCustom {
                        AnyView(
                            VStack {
                                Text("自定义内容")
                                YQSUIDialogDismissButton("关闭")
                            }
                            .padding()
                        )
                    }
                }
            }
            .navigationTitle("Demo")
        }
        .yqsUIDialog(dialogManager) // 将对话框层挂载在应用页面上
    }
}

2) 在混合 UIKit 应用中（AppDelegate）

// 在 AppDelegate 中启用
YQSUIDialogManager.initializeForUIKit()

// 任意时刻展示全局对话框
let dialog = YQSUIDialog(title: "网络错误", message: "请重试", style: .alert, actions: [YQSUIDialogAction(title: "确定")])
YQSUIDialogManager.showGlobal(dialog)

注意事项与建议

- custom 模式下的 customContent 会以 `AnyView` 形式存储并由 `UIHostingController` 在 UIKit 模式中承载，注意不要在 customContent 中强引用外部 controller/manager，推荐使用 `YQSUIDialogDismissButton` 或 `yqsUIDialogDismissAction` 注入的关闭回调。
- ObjC/全局 API：为支持 Objective-C 调用，库提供了简单的 `showGlobal(_:message:style:dismissOnBackgroundTap:)`，但 custom 内容无法通过 ObjC API 传递。
- 在复杂 UI 中展示时，建议将 `yqsUIDialog(_:)` 放在应用或页面的根视图以保证遮罩覆盖全局内容。
- 在多窗口或 scene 环境下（iPadOS 多窗口），UIKit 全局 overlay 逻辑基于 `UIApplication.shared.currentTopViewController` 的实现，可能需要根据应用窗口管理策略适配。
- 按钮 role 的样式与布局在 UIKit/SwiftUI 两处均有实现，业务侧不能扩展 `YQSUIDialogActionRole` 的用法以保证可预测的样式。

如何贡献

欢迎提交 issue 或 PR：
- 支持更多自定义动画/样式
- 改善 iPad 多窗口下的全局展示策略
- 提供更多可访问性文本及 VoiceOver 支持

作者: yumumu
文件: YQSUIDialog.swift
