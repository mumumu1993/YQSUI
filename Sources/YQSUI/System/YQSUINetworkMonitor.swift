//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 网络状态监听工具
🎯 6A阶段: Approve
*/

import Foundation
import Network
#if canImport(CoreTelephony)
import CoreTelephony
#endif

// region Network Monitor
public final class YQSUINetworkMonitor: ObservableObject {
    
    // 📍 网络连接状态枚举
    public enum ConnectionStatus {
        case connected          // 已连接
        case disconnected       // 未连接
        case requiresConnection // 需要连接
    }

    public enum NetworkType: Equatable {
        case none
        case wifi
        case cellular2G
        case cellular3G
        case cellular4G
        case cellular5G
        case ethernet
        case unknown

        public var name: String {
            switch self {
            case .none: return "None"
            case .wifi: return "WiFi"
            case .cellular2G: return "Cellular 2G"
            case .cellular3G: return "Cellular 3G"
            case .cellular4G: return "Cellular 4G"
            case .cellular5G: return "Cellular 5G"
            case .ethernet: return "Ethernet"
            case .unknown: return "Unknown"
            }
        }
    }
    
    // 📍 单例模式
    public static let shared = YQSUINetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.yqsui.networkMonitorQueue")

#if canImport(CoreTelephony)
    private let telephonyInfo = CTTelephonyNetworkInfo()
#endif
    
    @Published public private(set) var status: ConnectionStatus = .requiresConnection
    @Published public private(set) var isExpensive: Bool = false     // 是否为蜂窝网络 (收费网络)
    @Published public private(set) var isConstrained: Bool = false   // 是否处于低数据模式
    @Published public private(set) var networkType: NetworkType = .unknown
    
    private init() {
        setupMonitor()
    }
    
    // 📍 初始化与状态分发
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 更新连接状态
                if path.status == .satisfied {
                    self.status = .connected
                } else if path.status == .unsatisfied {
                    self.status = .disconnected
                } else {
                    self.status = .requiresConnection
                }
                
                // 更新网络属性
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
                self.networkType = self.resolveNetworkType(from: path)
                
                LogDebug("Network status changed -> Status: \(self.status), Type: \(self.networkType.name), Expensive: \(self.isExpensive), Constrained: \(self.isConstrained)")
            }
        }
    }

    private func resolveNetworkType(from path: NWPath) -> NetworkType {
        guard path.status == .satisfied else { return .none }

        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }

        if path.usesInterfaceType(.cellular) {
#if canImport(CoreTelephony)
            let radioTech: String? = {
                if #available(iOS 12.0, *) {
                    return telephonyInfo.serviceCurrentRadioAccessTechnology?.values.first
                } else {
                    return telephonyInfo.currentRadioAccessTechnology
                }
            }()

            switch radioTech {
            case CTRadioAccessTechnologyGPRS,
                CTRadioAccessTechnologyEdge,
                CTRadioAccessTechnologyCDMA1x:
                return .cellular2G
            case CTRadioAccessTechnologyWCDMA,
                CTRadioAccessTechnologyHSDPA,
                CTRadioAccessTechnologyHSUPA,
                CTRadioAccessTechnologyCDMAEVDORev0,
                CTRadioAccessTechnologyCDMAEVDORevA,
                CTRadioAccessTechnologyCDMAEVDORevB,
                CTRadioAccessTechnologyeHRPD:
                return .cellular3G
            case CTRadioAccessTechnologyLTE:
                return .cellular4G
            
            default:
                if #available(iOS 14.1, *) {
                    if radioTech == CTRadioAccessTechnologyNR || radioTech == CTRadioAccessTechnologyNRNSA {
                        return .cellular5G
                    }
                }
                return .unknown
            }
#else
            return .unknown
#endif
        }

        return .unknown
    }
    
    // 📍 开始监听
    public func start() {
        monitor.start(queue: queue)
    }
    
    // 📍 停止监听
    public func stop() {
        monitor.cancel()
    }
}
// endregion
