//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 全局加载 HUD
🎯 6A阶段: Approve
*/

import SwiftUI

// MARK: - Global Loading Manager
public final class YQSUILoadingManager: ObservableObject {
    @Published public var isShowing: Bool = false
    @Published public var title: String? = nil
    
    // 📍 单例模式
    public static let shared = YQSUILoadingManager()
    
    private init() {}
    
    // 📍 显示 Loading
    public func show(title: String? = nil) {
        DispatchQueue.main.async {
            self.title = title
            withAnimation {
                self.isShowing = true
            }
        }
    }
    
    // 📍 隐藏 Loading
    public func hide() {
        DispatchQueue.main.async {
            withAnimation {
                self.isShowing = false
                self.title = nil
            }
        }
    }
}

// MARK: - Loading View
private struct YQSUILoadingView: View {
    let title: String?
    
    var body: some View {
        ZStack {
            // 📍 背景遮罩
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // 📍 内部容器
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                if let title = title, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        // 阻止底部事件穿透
        .allowsHitTesting(true)
    }
}

// MARK: - View Modifier
public struct YQSUILoadingModifier: ViewModifier {
    @ObservedObject private var manager: YQSUILoadingManager
    
    public init(manager: YQSUILoadingManager = .shared) {
        self.manager = manager
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if manager.isShowing {
                YQSUILoadingView(title: manager.title)
                    .zIndex(999)
            }
        }
    }
}

public extension View {
    // 📍 添加全局 Loading 挂载点
    func yqs_loading() -> some View {
        self.modifier(YQSUILoadingModifier())
    }
}
