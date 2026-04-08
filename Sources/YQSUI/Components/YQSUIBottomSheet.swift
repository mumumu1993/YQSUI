//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 底部半屏弹窗
🎯 6A阶段: Approve
*/

import SwiftUI

// region Bottom Sheet
public struct YQSUIBottomSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent
    
    // 📍 配置项
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let grabberVisible: Bool
    let dismissOnTapOutside: Bool
    
    @State private var offset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    public init(
        isPresented: Binding<Bool>,
        backgroundColor: Color = Color(UIColor.systemBackground),
        cornerRadius: CGFloat = 20,
        grabberVisible: Bool = true,
        dismissOnTapOutside: Bool = true,
        @ViewBuilder content: @escaping () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.grabberVisible = grabberVisible
        self.dismissOnTapOutside = dismissOnTapOutside
        self.sheetContent = content
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                // 📍 半透明背景
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if dismissOnTapOutside {
                            hideSheet()
                        }
                    }
                    .transition(.opacity)
                
                // 📍 底部弹窗容器
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // 📍 拖拽指示器
                        if grabberVisible {
                            Capsule()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 5)
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                        }
                        
                        sheetContent()
                            .padding(.bottom, YQSUISafeArea.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor)
                    .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                    .offset(y: offset > 0 ? offset : 0)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    offset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    hideSheet()
                                } else {
                                    withAnimation(.spring()) {
                                        offset = 0
                                    }
                                }
                            }
                    )
                }
                .transition(.move(edge: .bottom))
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isPresented)
    }
    
    // 📍 隐藏方法
    private func hideSheet() {
        withAnimation {
            isPresented = false
            offset = 0
        }
    }
}

// MARK: - Helper Extension for Partial Rounded Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - View Extension API
public extension View {
    // 📍 暴露给外部调用的 API
    func yqs_bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        backgroundColor: Color = Color(UIColor.systemBackground),
        cornerRadius: CGFloat = 20,
        grabberVisible: Bool = true,
        dismissOnTapOutside: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            YQSUIBottomSheet(
                isPresented: isPresented,
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                grabberVisible: grabberVisible,
                dismissOnTapOutside: dismissOnTapOutside,
                content: content
            )
        )
    }
}
// endregion
