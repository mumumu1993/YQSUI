//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 安全定时器 (GCD 封装)
🎯 6A阶段: Approve
*/

import Foundation

// region Safe Timer
public final class YQSUITimerUtil {
    
    // 📍 定时器持有字典，用于全局管理不同的定时器任务
    private static var timers: [String: DispatchSourceTimer] = [:]
    private static let timerQueue = DispatchQueue(label: "com.yqsui.timerQueue", attributes: .concurrent)
    private static let lock = NSLock()
    
    // 📍 启动一个定时任务 (如果不传 name，则随机生成一个标识符)
    @discardableResult
    public static func start(
        name: String = UUID().uuidString,
        timeInterval: TimeInterval,
        repeats: Bool = true,
        queue: DispatchQueue = .main,
        action: @escaping (() -> Void)
    ) -> String {
        
        lock.lock()
        // 如果存在同名定时器，先取消
        if let existingTimer = timers[name] {
            existingTimer.cancel()
            timers.removeValue(forKey: name)
        }
        
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        
        if repeats {
            timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        } else {
            timer.schedule(deadline: .now() + timeInterval)
        }
        
        timer.setEventHandler {
            if !repeats {
                cancel(name: name)
            }
            queue.async {
                action()
            }
        }
        
        timers[name] = timer
        timer.resume()
        lock.unlock()
        
        return name
    }
    
    // 📍 取消指定定时任务
    public static func cancel(name: String) {
        lock.lock()
        if let timer = timers[name] {
            timer.cancel()
            timers.removeValue(forKey: name)
        }
        lock.unlock()
    }
    
    // 📍 取消所有定时任务
    public static func cancelAll() {
        lock.lock()
        for (_, timer) in timers {
            timer.cancel()
        }
        timers.removeAll()
        lock.unlock()
    }
    
    // 📍 判断定时器是否在运行
    public static func isRunning(name: String) -> Bool {
        lock.lock()
        let isRunning = timers[name] != nil
        lock.unlock()
        return isRunning
    }
}
// endregion
