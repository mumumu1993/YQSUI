//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 防抖与节流工具
🎯 6A阶段: Approve
*/

import Foundation

// region Debounce & Throttle
public struct YQSUITimer {
    
    // 📍 防抖 (Debounce)
    /// 在指定延迟时间后执行。如果在延迟时间内再次调用，则重新开始计时。(即：只执行最后一次)
    /// - Parameters:
    ///   - delay: 延迟时间(秒)
    ///   - queue: 派发队列，默认主队列
    ///   - action: 需要执行的闭包操作
    /// - Returns: 包装后的防抖闭包
    public static func debounce(
        delay: TimeInterval,
        queue: DispatchQueue = .main,
        action: @escaping () -> Void
    ) -> () -> Void {
        var workItem: DispatchWorkItem?
        return {
            workItem?.cancel()
            workItem = DispatchWorkItem(block: action)
            queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
        }
    }
    
    // 📍 节流 (Throttle)
    /// 在指定时间间隔内，无论调用多少次，只执行第一次。(常用于防止按钮快速连点)
    /// - Parameters:
    ///   - delay: 节流时间间隔(秒)
    ///   - queue: 派发队列，默认主队列
    ///   - action: 需要执行的闭包操作
    /// - Returns: 包装后的节流闭包
    public static func throttle(
        delay: TimeInterval,
        queue: DispatchQueue = .main,
        action: @escaping () -> Void
    ) -> () -> Void {
        var lastFireTime = DispatchTime.now()
        var isFirstCall = true
        
        return {
            let now = DispatchTime.now()
            let timeSinceLast = Double(now.uptimeNanoseconds - lastFireTime.uptimeNanoseconds) / 1_000_000_000
            
            if isFirstCall || timeSinceLast >= delay {
                isFirstCall = false
                lastFireTime = now
                queue.async(execute: action)
            }
        }
    }
}
// endregion
