//
//  YQSUIDialog.swift
//  Project
//
//  Created by yumumu on 2026/1/23.
//  Copyright © 2026 Thread0. All rights reserved.
//

import SwiftUI
import UIKit

public enum YQSUIDialogActionRole: Equatable {
    // 注意：Equatable 用于对比按钮样式，业务侧不应扩展该枚举。
    case normal // 默认样式
    case cancel // 强调取消样式
    case destructive // 强调破坏性操作样式
}

public struct YQSUIDialogAction: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let role: YQSUIDialogActionRole

    /// 注意：闭包不参与 Equatable；用于点击按钮后的业务回调。
    public let handler: (() -> Void)?

    public init(id: UUID = UUID(),
                title: String,
                role: YQSUIDialogActionRole = .normal,
                handler: (() -> Void)? = nil) {
        self.id = id
        self.title = title
        self.role = role
        self.handler = handler
    }

    public static func == (lhs: YQSUIDialogAction, rhs: YQSUIDialogAction) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.role == rhs.role
    }
}

public enum YQSUIDialogStyle: Equatable {
    case alert
    case confirm
    /// 允许完全自定义内容（仍复用遮罩、动画、关闭逻辑）
    case custom
}

public struct YQSUIDialog: Identifiable, Equatable {
    public let id: UUID
    public let title: String?
    public let message: String?
    public let style: YQSUIDialogStyle
    public let actions: [YQSUIDialogAction]
    public let dismissOnBackgroundTap: Bool

    /// 当 style == .custom 时，使用 customContent 返回自定义内容。
    /// 注意：闭包不参与 Equatable。
    public let customContent: (() -> AnyView)?

    public init(id: UUID = UUID(),
                title: String? = nil,
                message: String? = nil,
                style: YQSUIDialogStyle = .alert,
                actions: [YQSUIDialogAction] = [],
                dismissOnBackgroundTap: Bool = false,
                customContent: (() -> AnyView)? = nil) {
        self.id = id
        self.title = title
        self.message = message
        self.style = style
        self.actions = actions
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.customContent = customContent
    }

    public static func == (lhs: YQSUIDialog, rhs: YQSUIDialog) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.style == rhs.style &&
        lhs.actions == rhs.actions &&
        lhs.dismissOnBackgroundTap == rhs.dismissOnBackgroundTap
    }
}

public final class YQSUIDialogManager: ObservableObject {
    @Published public private(set) var dialog: YQSUIDialog?

    public init() {}

    public func show(_ dialog: YQSUIDialog) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.92)) {
                self.dialog = dialog
            }
        }
    }

    public func hide() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            withAnimation(.spring(response: 0.22, dampingFraction: 0.92)) {
                self.dialog = nil
            }
        }
    }

    // MARK: - 便捷 API（减少业务侧拼装步骤）

    public func showAlert(title: String? = nil,
                          message: String? = nil,
                          buttonTitle: String = "确定",
                          dismissOnBackgroundTap: Bool = false,
                          onTap: (() -> Void)? = nil) {
        let action = YQSUIDialogAction(title: buttonTitle, role: .normal) { [weak self] in
            onTap?()
            self?.hide()
        }

        show(YQSUIDialog(title: title,
                         message: message,
                         style: .alert,
                         actions: [action],
                         dismissOnBackgroundTap: dismissOnBackgroundTap,
                         customContent: nil))
    }

    public func showConfirm(title: String? = nil,
                            message: String? = nil,
                            confirmTitle: String = "确定",
                            cancelTitle: String = "取消",
                            dismissOnBackgroundTap: Bool = true,
                            onConfirm: (() -> Void)? = nil,
                            onCancel: (() -> Void)? = nil) {
       
        let confirm = YQSUIDialogAction(title: confirmTitle, role: .normal) { [weak self] in
            onConfirm?()
            self?.hide()
        }
        let cancel = YQSUIDialogAction(title: cancelTitle, role: .cancel) { [weak self] in
            onCancel?()
            self?.hide()
        }

        show(YQSUIDialog(title: title,
                         message: message,
                         style: .confirm,
                         actions: [confirm, cancel],
                         dismissOnBackgroundTap: dismissOnBackgroundTap,
                         customContent: nil))
    }

    public func showCustom(dismissOnBackgroundTap: Bool = false,
                           content: @escaping () -> AnyView) {
        show(YQSUIDialog(title: nil,
                         message: nil,
                         style: .custom,
                         actions: [],
                         dismissOnBackgroundTap: dismissOnBackgroundTap,
                         customContent: content))
    }

    /// iOS 14+：无需在业务侧写 AnyView。
    public func showCustom<Content: View>(dismissOnBackgroundTap: Bool = false,
                                          @ViewBuilder content: @escaping () -> Content) {
        showCustom(dismissOnBackgroundTap: dismissOnBackgroundTap) {
            AnyView(content())
        }
    }

    // MARK: - UIKit compatibility (global presenter)

    public static let shared = YQSUIDialogManager()

    private static var isUIKitMode = false
    private static var dialogOverlayView: UIView?
    private static var currentDialog: YQSUIDialog?
    private static var dialogHostingController: UIViewController?

    /// Call in AppDelegate when the app uses UIKit presentation.
    @objc public static func initializeForUIKit() {
        isUIKitMode = true
    }

    /// Present a dialog globally. If UIKit mode is enabled it will render a UIKit overlay; otherwise it will route to the SwiftUI manager.
    public static func showGlobal(_ dialog: YQSUIDialog) {
        if isUIKitMode {
            showInUIKit(dialog)
        } else {
            shared.show(dialog)
        }
    }

    /// ObjC-friendly convenience to show simple built-in alerts (confirm/alert). style: 0 = alert, 1 = confirm, 2 = custom (no-op for custom here).
    @objc public static func showGlobal(_ title: String?, message: String?, style: Int, dismissOnBackgroundTap: Bool) {
        let dialogStyle: YQSUIDialogStyle
        switch style {
        case 1: dialogStyle = .confirm
        case 2: dialogStyle = .custom
        default: dialogStyle = .alert
        }

        switch dialogStyle {
        case .alert:
            let action = YQSUIDialogAction(title: "确定", role: .normal) {
                // nothing extra
            }
            showGlobal(YQSUIDialog(title: title,
                                    message: message,
                                    style: .alert,
                                    actions: [action],
                                    dismissOnBackgroundTap: dismissOnBackgroundTap,
                                    customContent: nil))
        case .confirm:
            let confirm = YQSUIDialogAction(title: "确定", role: .normal) {}
            let cancel = YQSUIDialogAction(title: "取消", role: .cancel) {}
            showGlobal(YQSUIDialog(title: title,
                                    message: message,
                                    style: .confirm,
                                    actions: [confirm, cancel],
                                    dismissOnBackgroundTap: dismissOnBackgroundTap,
                                    customContent: nil))
        case .custom:
            // Cannot supply arbitrary custom content from ObjC — ignore.
            break
        }
    }

    /// Hide globally.
    public static func hideGlobal() {
        if isUIKitMode {
            DispatchQueue.main.async {
                guard let overlay = dialogOverlayView else { return }
                UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut) {
                    overlay.alpha = 0
                    overlay.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                } completion: { _ in
                    overlay.removeFromSuperview()
                    dialogOverlayView = nil
                    currentDialog = nil
                    dialogHostingController?.view.removeFromSuperview()
                    dialogHostingController = nil
                }
            }
        } else {
            shared.hide()
        }
    }

    private static func showInUIKit(_ dialog: YQSUIDialog) {
        DispatchQueue.main.async {
            guard let currentVC = UIApplication.shared.currentTopViewController else { return }
            // Remove existing overlay
            dialogOverlayView?.removeFromSuperview()
            currentDialog = dialog
            dialogHostingController?.view.removeFromSuperview()
            dialogHostingController = nil

            // Overlay
            let overlay = UIView(frame: currentVC.view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            overlay.alpha = 0
            overlay.translatesAutoresizingMaskIntoConstraints = false

            // Tap to dismiss background if allowed
            let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped(_:)))
            overlay.addGestureRecognizer(tap)

            // Card
            let card = UIView()
            card.backgroundColor = UIColor.systemBackground
            card.layer.cornerRadius = 14
            card.layer.masksToBounds = true
            card.translatesAutoresizingMaskIntoConstraints = false

            overlay.addSubview(card)

            // Content
            if dialog.style == .custom, let custom = dialog.customContent {
                // Host SwiftUI custom content without messing with nav hierarchy
                let hosting = UIHostingController(rootView: custom().yqsUIDialogDismissAction { hideGlobal() })
                let hostingView = hosting.view ?? UIView()
                hostingView.backgroundColor = .clear
                hostingView.translatesAutoresizingMaskIntoConstraints = false
                dialogHostingController = hosting
                card.addSubview(hostingView)
                NSLayoutConstraint.activate([
                    hostingView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
                    hostingView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
                    hostingView.topAnchor.constraint(equalTo: card.topAnchor),
                    hostingView.bottomAnchor.constraint(equalTo: card.bottomAnchor)
                ])
             } else {
                 // Built-in alert/confirm layout
                 let stack = UIStackView()
                 stack.axis = .vertical
                 stack.spacing = 12
                 stack.alignment = .fill
                 stack.translatesAutoresizingMaskIntoConstraints = false

                if let title = dialog.title, !title.isEmpty {
                    let titleLabel = UILabel()
                    titleLabel.text = title
                    titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
                    titleLabel.textAlignment = .center
                    titleLabel.numberOfLines = 0
                    stack.addArrangedSubview(titleLabel)
                }
                if let message = dialog.message, !message.isEmpty {
                    let msgLabel = UILabel()
                    msgLabel.text = message
                    msgLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
                    msgLabel.textColor = UIColor.secondaryLabel
                    msgLabel.textAlignment = .center
                    msgLabel.numberOfLines = 0
                    stack.addArrangedSubview(msgLabel)
                }

                // Buttons
                if !dialog.actions.isEmpty {
                    let buttonsContainer = UIStackView()
                    buttonsContainer.axis = .vertical
                    buttonsContainer.spacing = 8
                    buttonsContainer.alignment = .fill
                    buttonsContainer.translatesAutoresizingMaskIntoConstraints = false

                    for action in dialog.actions {
                        let btn = UIButton(type: .system)
                        btn.setTitle(action.title, for: .normal)
                        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: action.role == .cancel ? .regular : .semibold)

                        switch action.role {
                        case .normal:
                            btn.setTitleColor(UIColor.white, for: .normal)
                            btn.backgroundColor = UIColor(named: "AppBlue") ?? UIColor.systemBlue
                        case .cancel:
                            btn.setTitleColor(UIColor.gray, for: .normal)
                            btn.backgroundColor = UIColor.clear
                        case .destructive:
                            btn.setTitleColor(UIColor.systemRed, for: .normal)
                            btn.backgroundColor = UIColor.clear
                        }

                        btn.layer.cornerRadius = 10
                        btn.clipsToBounds = true
                        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

                        // Hook up action
                        btn.addAction(UIAction { _ in
                            // call handler
                            action.handler?()
                            // hide overlay
                            hideGlobal()
                        }, for: .touchUpInside)

                        buttonsContainer.addArrangedSubview(btn)
                        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
                    }

                    stack.addArrangedSubview(buttonsContainer)
                }

                card.addSubview(stack)

                NSLayoutConstraint.activate([
                    stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                    stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                    stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                    stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
                ])
            }

            currentVC.view.addSubview(overlay)
            dialogOverlayView = overlay

            // Layout
            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: currentVC.view.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: currentVC.view.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: currentVC.view.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: currentVC.view.bottomAnchor),

                card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                card.widthAnchor.constraint(lessThanOrEqualTo: overlay.widthAnchor, multiplier: 0.9)
            ])

            // Entrance animation
            card.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            overlay.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                overlay.alpha = 1
                card.transform = CGAffineTransform.identity
            }
        }
    }

    @objc private static func overlayTapped(_ gesture: UITapGestureRecognizer) {
        guard let dialog = currentDialog else { return }
        if dialog.dismissOnBackgroundTap {
            hideGlobal()
        }
    }
}

// MARK: - 让自定义内容可直接 dismiss（避免到处 capture manager）

public struct YQSUIDialogDismissActionKey: EnvironmentKey {
    public static let defaultValue: () -> Void = {}
}

public extension EnvironmentValues {
    var yqsuiDialogDismiss: () -> Void {
        get { self[YQSUIDialogDismissActionKey.self] }
        set { self[YQSUIDialogDismissActionKey.self] = newValue }
    }
}

/// 在自定义 Dialog Content 内部使用：`dialogDismiss()`
public extension View {
    func yqsUIDialogDismissAction(_ action: @escaping () -> Void) -> some View {
        environment(\.yqsuiDialogDismiss, action)
    }
}

/// 自定义内容内部可直接调用隐藏
public struct YQSUIDialogDismissButton: View {
    @Environment(\.yqsuiDialogDismiss) private var dismiss

    private let title: String

    public init(_ title: String = "关闭") {
        self.title = title
    }

    public var body: some View {
        Button(title) { dismiss() }
    }
}

public struct YQSUIDialogCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal,16)
            .padding(.vertical,10)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 10)
            .accessibilityIdentifier("YQSUIDialogCard")
    }
}

public struct YQSUIDialogBuiltInView: View {
    let dialog: YQSUIDialog
    let onActionTap: (YQSUIDialogAction) -> Void

    private func foreground(for role: YQSUIDialogActionRole) -> Color {
        switch role {
        case .normal: return .white
        case .cancel: return .gray
        case .destructive: return .red
        }
    }
    
    private func background(for role: YQSUIDialogActionRole) -> Color {
        switch role {
        case .normal: return Color("AppBlue")
        case .cancel: return .clear
        case .destructive: return .clear
        }
    }
    
    private func pressedBackground(for role: YQSUIDialogActionRole) -> Color {
        switch role {
        case .normal: return .gray
        case .cancel: return .black.opacity(0.3)
        case .destructive: return .black.opacity(0.3)
        }
    }

    private func fontWeight(for role: YQSUIDialogActionRole) -> Font.Weight {
        switch role {
        case .cancel: return .regular
        case .normal, .destructive: return .semibold
        }
    }

    public var body: some View {
        VStack(spacing: 20) {
            if let title = dialog.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            if let message = dialog.message, !message.isEmpty {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !dialog.actions.isEmpty {
                VStack(spacing: 10) {
                    ForEach(dialog.actions) { action in
                        Button {
                            onActionTap(action)
                        } label: {
                            Text(action.title)
                                .frame(maxWidth: .infinity)
                                .font(.body.weight(fontWeight(for: action.role)))
                                .foregroundColor(foreground(for: action.role))
                                .padding(.vertical, 10)
                        }
                        .yqsUIPressEffect(normalColor: background(for: action.role),
                                            pressedColor: pressedBackground(for: action.role))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .accessibilityIdentifier("YQSUIDialogAction_\(action.id.uuidString)")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

public struct YQSUIDialogModifier: ViewModifier {
    @ObservedObject public var manager: YQSUIDialogManager

    public init(manager: YQSUIDialogManager) {
        self.manager = manager
    }

    public func body(content: Content) -> some View {
        ZStack {
            content

            if let dialog = manager.dialog {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .accessibilityIdentifier("YQSUIDialogBackdrop")
                    .onTapGesture {
                        if dialog.dismissOnBackgroundTap {
                            manager.hide()
                        }
                    }
                    .transition(.opacity)

                Group {
                    if dialog.style == .custom, let custom = dialog.customContent {
                        YQSUIDialogCard {
                            custom()
                                .yqsUIDialogDismissAction { manager.hide() }
                        }
                    } else {
                        YQSUIDialogCard {
                            YQSUIDialogBuiltInView(dialog: dialog) { action in
                                action.handler?()
                                // 兜底避免业务侧忘记关闭
                                manager.hide()
                            }
                        }
                    }
                }
                .padding(.horizontal, 36)
                .transition(.scale(scale: 0.96).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.92), value: manager.dialog)
    }
}

public extension View {
    /// 挂载对话框覆盖层；建议放在页面最外层（如 NavigationStack 外层）保证覆盖全局。
    func yqsUIDialog(_ manager: YQSUIDialogManager) -> some View {
        self.modifier(YQSUIDialogModifier(manager: manager))
    }
}
