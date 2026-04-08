YQSUI — 缺省页与占位图 (YQSUIEmptyView.swift)

简介

`YQSUIEmptyView.swift` 是一个用于在无数据或网络错误时展示的占位图组件。该组件提供了一套高度可配置的 `YQSUIEmptyConfig` 结构，支持本地图片或 SF Symbols 系统图标，并能够显示标题、描述文字，以及一个可选的重新加载/操作按钮。

主要能力

- 统一的空页面展示（暂无数据、网络未连接、内容为空）。
- 支持传入系统内置图标 (`systemImageName`) 或本地图片资源 (`imageName`)。
- 可选展示副标题 (`description`) 和操作按钮 (`buttonTitle`, `action`)。

API 概览

- YQSUIEmptyConfig: 缺省页配置模型
  - imageName: String?（优先使用本地图片）
  - systemImageName: String?（默认值 "tray"）
  - title: String（主标题，如“暂无数据”）
  - description: String?（副标题说明）
  - buttonTitle: String?（操作按钮标题，如“点击重试”）
  - action: (() -> Void)?（按钮点击回调）

- YQSUIEmptyView: 占位图主体视图
  - init(config: YQSUIEmptyConfig): 根据配置实例化缺省视图。

使用示例

import SwiftUI

struct ContentView: View {
    @State private var items: [String] = []
    
    var body: some View {
        if items.isEmpty {
            // 展示缺省页
            YQSUIEmptyView(config: YQSUIEmptyConfig(
                systemImageName: "wifi.slash",
                title: "网络未连接",
                description: "请检查您的网络设置后重试",
                buttonTitle: "刷新",
                action: {
                    print("执行重新加载数据逻辑")
                    self.loadData()
                }
            ))
        } else {
            List(items, id: \.self) { item in
                Text(item)
            }
        }
    }
    
    func loadData() {
        // ...
    }
}

注意事项与建议

- `imageName` 和 `systemImageName` 互斥，当两者同时提供时优先渲染本地图片 `imageName`。
- 如果不需要操作按钮，可以将 `buttonTitle` 和 `action` 留空（nil）。
- 缺省页内部已经做了 `maxWidth: .infinity, maxHeight: .infinity` 处理，会自动撑满父容器。

作者: yumumu
文件: YQSUIEmptyView.swift
