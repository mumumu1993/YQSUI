YQSUI — 自定义导航栏 (YQSUINavigationBar.swift)

简介

`YQSUINavigationBar.swift` 提供了一个用于替换系统原生 `NavigationBar` 的高度可定制的导航栏组件。它完全基于 SwiftUI 构建，并在顶部保留了系统状态栏（Status Bar）的安全区高度，支持完全自定义的左、中、右区域视图，并附带了快捷的标题和返回按钮构造方法。

主要能力

- 完全可配置的 `leftContent`, `centerContent`, `rightContent` 区域。
- 自动处理顶部安全区 (`YQSUISafeArea.top`) 占位。
- 可选展示底部细线分隔（`showSeparator`）。
- 提供两个便捷扩展构造器：仅标题 + 默认返回按钮，以及标题 + 默认返回 + 自定义右侧操作区。

API 概览

- YQSUINavigationBar: 自定义导航栏视图
  - init(backgroundColor: Color, showSeparator: Bool, @ViewBuilder leftContent: () -> LeftContent, @ViewBuilder centerContent: () -> CenterContent, @ViewBuilder rightContent: () -> RightContent): 完整构造器。
  - init(title: String, backgroundColor: Color, showSeparator: Bool, onBack: (() -> Void)?): 快捷构造器（仅标题和返回）。
  - init(title: String, backgroundColor: Color, showSeparator: Bool, onBack: (() -> Void)?, @ViewBuilder rightContent: () -> RightContent): 快捷构造器（标题、返回和右侧自定义）。

使用示例

import SwiftUI

struct CustomNavBarView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            YQSUINavigationBar(
                title: "用户详情",
                backgroundColor: .white,
                showSeparator: true,
                onBack: {
                    presentationMode.wrappedValue.dismiss()
                },
                rightContent: {
                    Button(action: { print("编辑") }) {
                        Text("编辑")
                            .font(.system(size: 15))
                            .foregroundColor(.blue)
                    }
                }
            )
            
            // 页面内容区
            ScrollView {
                Text("这是一个自定义导航栏页面的内容...")
                    .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // 隐藏系统默认导航栏
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
}

注意事项与建议

- 在包含 `NavigationView` 或 `NavigationStack` 的体系下使用此组件时，请务必配合 `.navigationBarHidden(true)` 和 `.ignoresSafeArea(edges: .top)`，以隐藏原生的导航条。
- 中间的 `title` 默认为 17pt, semibold，居中显示，左右内容通过 HStack 和 Spacer 进行排列，并留有默认边距（`padding(.horizontal, 16)`）。如果需要更复杂的居中或偏移，建议使用完整的自定义构造器。

作者: yumumu
文件: YQSUINavigationBar.swift
