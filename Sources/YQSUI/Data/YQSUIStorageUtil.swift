//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 轻量级持久化存储工具类 (UserDefaults 封装)
🎯 6A阶段: Approve
*/

import Foundation

// region Storage Utilities

// 📍 UserDefaults 属性包装器
@propertyWrapper
public struct YQSUIStorage<T> {
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults

    public init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    public var wrappedValue: T {
        get {
            return userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                userDefaults.removeObject(forKey: key)
            } else {
                userDefaults.set(newValue, forKey: key)
            }
        }
    }
}

// 📍 用于处理 Optional 类型的辅助协议
private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

// 📍 模型化存储扩展 (支持 Codable 对象)
@propertyWrapper
public struct YQSUICodableStorage<T: Codable> {
    private let key: String
    private let defaultValue: T?
    private let userDefaults: UserDefaults

    public init(key: String, defaultValue: T? = nil, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    public var wrappedValue: T? {
        get {
            guard let data = userDefaults.data(forKey: key) else { return defaultValue }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                LogError("Failed to read Codable object for key '\(key)': \(error)")
                return defaultValue
            }
        }
        set {
            guard let newValue = newValue else {
                userDefaults.removeObject(forKey: key)
                return
            }
            do {
                let data = try JSONEncoder().encode(newValue)
                userDefaults.set(data, forKey: key)
            } catch {
                LogError("Failed to save Codable object for key '\(key)': \(error)")
            }
        }
    }
}

// endregion

// MARK: - Example Usage (Commented Out)
/*
public struct YQSUISettings {
    @YQSUIStorage(key: "is_first_launch", defaultValue: true)
    public static var isFirstLaunch: Bool
    
    @YQSUICodableStorage(key: "user_info")
    public static var userInfo: UserInfoModel?
}
*/
