YQSUI — 底部半屏弹窗 (YQSUIBottomSheet.swift)

简介

`YQSUIBottomSheet.swift` 是一个提供给 SwiftUI 的底部半屏抽屉组件。通过 `ViewModifier` 形式，使得开发者能够在页面的任意地方挂载带有拖拽指示器、半透明遮罩背景的底部弹窗，常用于展示详细选项、过滤器或分享面板。

主要能力

- 支持拖拽手势关闭。
- 支持点击外部半透明背景遮罩关闭。
- 提供可配置的顶部“抓手（grabber）”和背景圆角。
- 支持内嵌任意复杂的自定义 SwiftUI 视图。

API 概览

- YQSUIBottomSheet: ViewModifier，底部弹窗修饰符。
  - 属性:
    - @Binding var isPresented: Bool (双向绑定，用于展示/隐藏)
    - backgroundColor: Color
    - cornerRadius: CGFloat
    - grabberVisible: Bool
    - dismissOnTapOutside: Bool

- SwiftUI 集成:
  - View.yqs_bottomSheet<Content: View>(isPresented: Binding<Bool>, backgroundColor: Color = Color(UIColor.systemBackground), cornerRadius: CGFloat = 20, grabberVisible: Bool = true, dismissOnTapOutside: Bool = true, @ViewBuilder content: @escaping () -> Content)

使用示例

import SwiftUI

struct ContentView: View {
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Button("显示底部弹窗") {
                showSheet = true
            }
        }
        // 挂载底部半屏弹窗
        .yqs_bottomSheet(isPresented: $showSheet, cornerRadius: 24, grabberVisible: true) {
            VStack(spacing: 20) {
                Text("分享至")
                    .font(.headline)
                    .padding(.top, 20)
                
                HStack(spacing: 40) {
                    Button(action: { print("微信") }) {
                        Image(systemName: "message.fill")
                            .font(.largeTitle)
                    }
                    Button(action: { print("朋友圈") }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.largeTitle)
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

注意事项与建议

- `.yqs_bottomSheet` 推荐挂载在 `ZStack` 或页面根容器上，确保能够盖住整个页面的其他元素。
- 当在内部视图（如列表或滚动视图）中使用时，请确保 `isPresented` 的作用域和生命周期被正确管理。
- 弹窗的内部内容 `content` 高度会根据子视图的大小自适应，且自动适配底部安全区（SafeArea）。

作者: yumumu
文件: YQSUIBottomSheet.swift
