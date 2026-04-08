//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 键盘监听与避让工具类
🎯 6A阶段: Approve
*/

import SwiftUI
import Combine

// region Keyboard Utilities
public final class YQSUIKeyboardUtil: ObservableObject {
    
    // 📍 键盘当前高度
    @Published public private(set) var keyboardHeight: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    // 📍 单例监听器
    public static let shared = YQSUIKeyboardUtil()
    
    private init() {
        setupKeyboardObservers()
    }
    
    private func setupKeyboardObservers() {
        // 监听键盘弹出
        let showPublisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        // 监听键盘收起
        let hidePublisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in 0 }
        
        Publishers.Merge(showPublisher, hidePublisher)
            .receive(on: RunLoop.main)
            .assign(to: \.keyboardHeight, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - Keyboard Adaptive Modifier
public struct YQSUIKeyboardAdaptiveModifier: ViewModifier {
    @ObservedObject private var keyboard = YQSUIKeyboardUtil.shared
    
    public func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboard.keyboardHeight)
            .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
    }
}

// MARK: - View Extension
public extension View {
    // 📍 自动避让键盘扩展 (给需要避让的输入视图调用)
    func yqs_keyboardAdaptive() -> some View {
        self.modifier(YQSUIKeyboardAdaptiveModifier())
    }
    
    // 📍 快捷收起键盘
    func yqs_hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
// endregion
