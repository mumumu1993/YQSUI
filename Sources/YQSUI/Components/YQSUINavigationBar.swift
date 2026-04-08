//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 自定义导航栏
🎯 6A阶段: Approve
*/

import SwiftUI

// region Custom Navigation Bar
public struct YQSUINavigationBar<LeftContent: View, CenterContent: View, RightContent: View>: View {
    
    // 📍 内部属性
    private let leftContent: LeftContent
    private let centerContent: CenterContent
    private let rightContent: RightContent
    
    private let backgroundColor: Color
    private let showSeparator: Bool
    
    // 📍 构造器 (全自定义)
    public init(
        backgroundColor: Color = Color(UIColor.systemBackground),
        showSeparator: Bool = true,
        @ViewBuilder leftContent: () -> LeftContent,
        @ViewBuilder centerContent: () -> CenterContent,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.backgroundColor = backgroundColor
        self.showSeparator = showSeparator
        self.leftContent = leftContent()
        self.centerContent = centerContent()
        self.rightContent = rightContent()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 📍 顶部安全区占位
            Spacer()
                .frame(height: YQSUISafeArea.top)
            
            // 📍 导航栏核心内容区
            ZStack {
                // 中间标题
                centerContent
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // 左右按钮
                HStack {
                    leftContent
                    Spacer()
                    rightContent
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 44) // 标准导航栏高度
            
            // 📍 底部细线分隔
            if showSeparator {
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
        }
        .background(backgroundColor)
        .ignoresSafeArea(.all, edges: .top)
    }
}

// MARK: - Convenient Extensions
public extension YQSUINavigationBar {
    
    // 📍 快捷构造器：只传标题，使用默认返回按钮
    init(
        title: String,
        backgroundColor: Color = Color(UIColor.systemBackground),
        showSeparator: Bool = true,
        onBack: (() -> Void)? = nil
    ) where LeftContent == AnyView, CenterContent == Text, RightContent == EmptyView {
        
        let left: AnyView = {
            if let onBack = onBack {
                return AnyView(
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                )
            } else {
                return AnyView(EmptyView())
            }
        }()
        
        self.init(
            backgroundColor: backgroundColor,
            showSeparator: showSeparator,
            leftContent: { left },
            centerContent: {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
            },
            rightContent: {
                EmptyView()
            }
        )
    }
    
    // 📍 快捷构造器：传标题 + 右侧按钮
    init(
        title: String,
        backgroundColor: Color = Color(UIColor.systemBackground),
        showSeparator: Bool = true,
        onBack: (() -> Void)? = nil,
        @ViewBuilder rightContent: () -> RightContent
    ) where LeftContent == AnyView, CenterContent == Text {
        
        let left: AnyView = {
            if let onBack = onBack {
                return AnyView(
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                )
            } else {
                return AnyView(EmptyView())
            }
        }()
        
        self.init(
            backgroundColor: backgroundColor,
            showSeparator: showSeparator,
            leftContent: { left },
            centerContent: {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
            },
            rightContent: rightContent
        )
    }
}

// MARK: - Previews (For Debugging)
#if DEBUG
struct YQSUINavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            YQSUINavigationBar(
                title: "首页",
                onBack: { print("返回") },
                rightContent: {
                    Button(action: { print("更多") }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                    }
                }
            )
            Spacer()
        }
    }
}
#endif
// endregion
