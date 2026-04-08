//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 触觉反馈工具类
🎯 6A阶段: Approve
*/

import UIKit
import Foundation

// region Haptic Feedback
public struct YQSUIHaptic {
    
    // 📍 成功反馈
    public static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // 📍 警告反馈
    public static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // 📍 错误反馈
    public static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // 📍 轻量级震动 (例如: 开关切换)
    public static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // 📍 中量级震动 (例如: 按下按钮)
    public static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // 📍 重量级震动 (例如: 物理碰撞)
    public static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // 📍 选择反馈 (例如: 滚轮滑动)
    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
// endregion
