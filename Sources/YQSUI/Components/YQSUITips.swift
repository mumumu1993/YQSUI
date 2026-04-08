//
//  YQSUITips.swift
//  Project
//
//  Created by yumumu on 2026/1/12.
//  Copyright © 2026 Thread0. All rights reserved.
//


import SwiftUI

public enum YQSUIToastStyle: Int {
    case info
    case success
    case warning
    case error

    var background: Color {
        switch self {
        case .info: return Color.black.opacity(0.8)
        case .success: return Color.green.opacity(0.85)
        case .warning: return Color.orange.opacity(0.9)
        case .error: return Color.red.opacity(0.9)
        }
    }

    var uiBackground: UIColor {
        switch self {
        case .info: return UIColor.black.withAlphaComponent(0.8)
        case .success: return UIColor.green.withAlphaComponent(0.85)
        case .warning: return UIColor.orange.withAlphaComponent(0.9)
        case .error: return UIColor.red.withAlphaComponent(0.9)
        }
    }

    var foreground: Color { Color.white }

    var uiForeground: UIColor { UIColor.white }

    var icon: String? {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }
}

public enum YQSUIToastPosition: Int {
    case top
    case center
    case bottom
}

public struct YQSUIToast: Identifiable, Equatable {
    public let id = UUID()
    public let message: String
    public let style: YQSUIToastStyle
    public let duration: TimeInterval
    public let position: YQSUIToastPosition

    public init(message: String,
                style: YQSUIToastStyle = .info,
                duration: TimeInterval = 2.0,
                position: YQSUIToastPosition = .bottom) {
        self.message = message
        self.style = style
        self.duration = duration
        self.position = position
    }
}

public final class YQSUIToastManager: ObservableObject {
    @Published private(set) var toast: YQSUIToast?
    private var hideWorkItem: DispatchWorkItem?

    public static let shared = YQSUIToastManager()

    private static var isUIKitMode = false
    private static var toastView: UIView?

    public init() {}

    public func show(_ message: String,
                     style: YQSUIToastStyle = .info,
                     duration: TimeInterval = 2.0,
                     position: YQSUIToastPosition = .bottom) {
        let toast = YQSUIToast(message: message, style: style, duration: duration, position: position)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            hideWorkItem?.cancel()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                self.toast = toast
            }
            let workItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    if self.toast?.id == toast.id {
                        self.toast = nil
                    }
                }
            }
            hideWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: workItem)
        }
    }

    public func hide() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            hideWorkItem?.cancel()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
                self.toast = nil
            }
        }
    }

    public static func showGlobal(_ message: String,
                                  style: YQSUIToastStyle = .info,
                                  duration: TimeInterval = 2.0,
                                  position: YQSUIToastPosition = .bottom) {
        if isUIKitMode {
            showInUIKit(message, style: style, duration: duration, position: position)
        } else {
            shared.show(message, style: style, duration: duration, position: position)
        }
    }

    @objc public static func showGlobal(_ message: String,
                                        style: Int,
                                        duration: TimeInterval,
                                        position: Int) {
        let toastStyle = YQSUIToastStyle(rawValue: style) ?? .info
        let toastPosition = YQSUIToastPosition(rawValue: position) ?? .bottom
        showGlobal(message, style: toastStyle, duration: duration, position: toastPosition)
    }

    @objc public static func initializeForUIKit() {
        isUIKitMode = true
    }

    private static func showInUIKit(_ message: String,
                                    style: YQSUIToastStyle,
                                    duration: TimeInterval,
                                    position: YQSUIToastPosition) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

            // Remove existing toast
            toastView?.removeFromSuperview()

            // Create toast view
            let toastView = UIView()
            toastView.backgroundColor = style.uiBackground
            toastView.layer.cornerRadius = 12
            toastView.clipsToBounds = true
            toastView.alpha = 0

            // Icon and label
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .center

            if let iconName = style.icon, let iconImage = UIImage(systemName: iconName) {
                let iconView = UIImageView(image: iconImage)
                iconView.tintColor = style.uiForeground
                iconView.contentMode = .scaleAspectFit
                iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
                iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                stackView.addArrangedSubview(iconView)
            }

            let label = UILabel()
            label.text = message
            label.textColor = style.uiForeground
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)

            toastView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
                stackView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 12),
                stackView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -12)
            ])

            window.addSubview(toastView)
            toastView.translatesAutoresizingMaskIntoConstraints = false

            // Position constraints
            let centerX = toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor)
            var topConstraint: NSLayoutConstraint
            var bottomConstraint: NSLayoutConstraint

            switch position {
            case .top:
                topConstraint = toastView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 48)
                bottomConstraint = NSLayoutConstraint() // dummy
            case .center:
                topConstraint = toastView.centerYAnchor.constraint(equalTo: window.centerYAnchor)
                bottomConstraint = NSLayoutConstraint() // dummy
            case .bottom:
                bottomConstraint = toastView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -48)
                topConstraint = NSLayoutConstraint() // dummy
            }

            NSLayoutConstraint.activate([
                centerX,
                position == .bottom ? bottomConstraint : topConstraint
            ])

            // Animate in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                toastView.alpha = 1
                toastView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }

            self.toastView = toastView

            // Auto hide
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                    toastView.alpha = 0
                    toastView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                } completion: { _ in
                    toastView.removeFromSuperview()
                    self.toastView = nil
                }
            }

            // Tap to dismiss
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toastTapped))
            toastView.addGestureRecognizer(tapGesture)
        }
    }

    @objc private static func toastTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            toastView?.alpha = 0
            toastView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            toastView?.removeFromSuperview()
            toastView = nil
        }
    }
}

private struct YQSUIToastView: View {
    let toast: YQSUIToast

    var body: some View {
        HStack(spacing: 8) {
            if let icon = toast.style.icon {
                Image(systemName: icon)
                    .foregroundColor(toast.style.foreground)
            }
            Text(toast.message)
                .foregroundColor(toast.style.foreground)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(toast.style.background)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .accessibilityIdentifier("YQSUIToastView")
    }
}

public struct YQSUIToastModifier: ViewModifier {
    @ObservedObject public var manager: YQSUIToastManager

    public init(manager: YQSUIToastManager) {
        self.manager = manager
    }

    private func alignment(for position: YQSUIToastPosition) -> Alignment {
        switch position {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        }
    }

    private func edge(for position: YQSUIToastPosition) -> Edge {
        switch position {
        case .top: return .top
        case .center: return .leading
        case .bottom: return .bottom
        }
    }

    public func body(content: Content) -> some View {
        ZStack(alignment: alignment(for: manager.toast?.position ?? .bottom)) {
            content
            if let toast = manager.toast {
                YQSUIToastView(toast: toast)
                    .padding(.horizontal, 24)
                    .padding(.bottom, toast.position == .bottom ? 48 : 0)
                    .padding(.top, toast.position == .top ? 48 : 0)
                    .onTapGesture { manager.hide() }
                    .transition(.move(edge: edge(for: toast.position)).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: manager.toast)
    }
}

public extension View {
    func yqsUIToast(_ manager: YQSUIToastManager) -> some View {
        self.modifier(YQSUIToastModifier(manager: manager))
    }
}

//OC调用
@objcMembers
public class YQSUIToastBridge: NSObject {
    public static func show(_ message: String,
                                  style: Int,
                                  duration: TimeInterval,
                                  position: Int) {
        let toastStyle = YQSUIToastStyle(rawValue: style) ?? .info
        let toastPosition = YQSUIToastPosition(rawValue: position) ?? .bottom
        YQSUIToastManager.showGlobal(message, style: toastStyle, duration: duration, position: toastPosition)
    }
    
    /// 供OC调用的隐藏方法
    public static func hide() {
        YQSUIToastManager.shared.hide()
    }
    
    //showInfo
    public static func showInfo(_ message: String){
        YQSUIToastManager.showGlobal(message,style: .info,position: .center)
    }
    
    //showSuccess
    public static func showSuccess(_ message: String){
        YQSUIToastManager.showGlobal(message,style: .success,position: .center)
    }
    
    //showWarning
    public static func showWarning(_ message: String){
        YQSUIToastManager.showGlobal(message,style: .warning,position: .center)
    }
    
    //showError
    public static func showError(_ message: String){
        YQSUIToastManager.showGlobal(message,style: .error,position: .center)
    }
}
