//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 日期处理工具类
🎯 6A阶段: Approve
*/

import Foundation

// region Date Utilities
public struct YQSUIDateUtil {
    
    // 📍 日期转字符串
    public static func string(from date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    // 📍 字符串转日期
    public static func date(from string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
    
    // 📍 时间戳(秒)转字符串
    public static func string(fromTimestamp timestamp: TimeInterval, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        return string(from: date, format: format)
    }
    
    // 📍 时间戳(毫秒)转字符串
    public static func string(fromMilliTimestamp timestamp: TimeInterval, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000.0)
        return string(from: date, format: format)
    }
}

public extension Date {
    // 📍 是否是今天
    var yqs_isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // 📍 是否是昨天
    var yqs_isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    // 📍 是否是今年
    var yqs_isThisYear: Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        let selfYear = Calendar.current.component(.year, from: self)
        return currentYear == selfYear
    }
}
// endregion
