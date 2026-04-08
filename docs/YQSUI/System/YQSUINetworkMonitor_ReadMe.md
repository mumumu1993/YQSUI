YQSUI — 网络状态监听 (YQSUINetworkMonitor.swift)

简介

`YQSUINetworkMonitor.swift` 提供了一个用于实时监听 iOS 设备网络连接状态的管理器。基于 Apple 官方推荐的 `Network.framework` (`NWPathMonitor`) 构建，不仅能够精准判断设备的网络连通性，还能区分当前是否处于收费网络（蜂窝数据）或低数据模式。

主要能力

- 基于 `ObservableObject` 实现的全局单例，可无缝集成到 SwiftUI 的 `@StateObject` / `@ObservedObject` 绑定中。
- 实时监听网络连接状态（`.connected`, `.disconnected`, `.requiresConnection`）。
- 实时获取当前网络是否为 `isExpensive`（收费，如蜂窝）或 `isConstrained`（低数据模式）。
- 获取当前网络类型 `networkType`：WiFi / Ethernet / 蜂窝网络（2G/3G/4G/5G）/ None / Unknown。

API 概览

- YQSUINetworkMonitor: 网络监听管理器
  - ConnectionStatus: 连接状态枚举
  - NetworkType: 网络类型枚举（包含 `name` 便捷展示）
  - static let shared: 单例实例
  - @Published public private(set) var status: ConnectionStatus
  - @Published public private(set) var isExpensive: Bool
  - @Published public private(set) var isConstrained: Bool
  - @Published public private(set) var networkType: NetworkType
  - func start(): 启动监听
  - func stop(): 停止监听

使用示例

import SwiftUI

// 1. 初始化并启动监听（建议在 App 启动时或根视图）
@main
struct MyApp: App {
    init() {
        YQSUINetworkMonitor.shared.start()
    }
    // ...
}

// 2. 在 SwiftUI 中响应状态变化
struct ContentView: View {
    @ObservedObject var networkMonitor = YQSUINetworkMonitor.shared
    
    var body: some View {
        VStack {
            Text("网络类型: \(networkMonitor.networkType.name)")
                .font(.footnote)
                .foregroundColor(.secondary)

            if networkMonitor.status == .disconnected {
                Text("网络已断开连接")
                    .foregroundColor(.red)
            } else if networkMonitor.isExpensive {
                Text("当前使用蜂窝数据，请注意流量消耗")
                    .foregroundColor(.orange)
            } else {
                Text("网络连接正常")
                    .foregroundColor(.green)
            }
        }
    }
}

注意事项与建议

- 由于 `NWPathMonitor` 在监听状态变化时运行在后台队列，所以工具类内部已经通过 `DispatchQueue.main.async` 派发到主线程更新属性，以确保驱动 SwiftUI UI 更新时的安全性。
- 记得在不再需要监听的时候调用 `stop()` 释放资源，不过如果是全局单例则通常无需停止。
- 蜂窝网络制式（2G/3G/4G/5G）通过 `CoreTelephony` 的 radio access technology 推断；在部分设备/权限/环境下可能返回 `Unknown`。

作者: yumumu
文件: YQSUINetworkMonitor.swift
