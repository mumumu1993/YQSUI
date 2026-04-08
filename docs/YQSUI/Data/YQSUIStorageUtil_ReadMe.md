YQSUI — 持久化存储 (YQSUIStorageUtil.swift)

简介

`YQSUIStorageUtil.swift` 提供了一组基于 Swift 5.1+ `@propertyWrapper` (属性包装器) 的本地持久化存储工具类。它们建立在系统的 `UserDefaults` 之上，使得我们在存储基础数据（如 `Bool`, `String` 等）或复杂的自定义对象（实现 `Codable` 协议）时，就像声明和操作一个普通静态变量一样方便。

主要能力

- `@YQSUIStorage`: 针对 `UserDefaults` 支持的基础数据类型（如 Int, Double, Bool, String, Data）。
- `@YQSUICodableStorage`: 针对遵守了 `Codable` 协议的任意自定义结构体/类对象，内部使用 `JSONEncoder/Decoder` 自动完成序列化和反序列化并保存至 `UserDefaults`。
- 在保存或读取时附带了 `YQSUILogger` 的异常信息捕获。

API 概览

- @YQSUIStorage<T>: 基础类型属性包装器
  - init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard)
  - var wrappedValue: T

- @YQSUICodableStorage<T: Codable>: Codable 对象属性包装器
  - init(key: String, defaultValue: T? = nil, userDefaults: UserDefaults = .standard)
  - var wrappedValue: T?

使用示例

import Foundation

// 1. 声明存储模型（必须遵守 Codable）
struct UserInfoModel: Codable {
    let id: String
    let name: String
    let avatar: String?
}

// 2. 在一个专门的管理类中使用属性包装器
struct YQSUISettings {
    // 存储基础数据，默认值为 true
    @YQSUIStorage(key: "is_first_launch", defaultValue: true)
    static var isFirstLaunch: Bool
    
    // 存储自定义模型，默认值为 nil
    @YQSUICodableStorage(key: "user_info")
    static var userInfo: UserInfoModel?
}

// 3. 在业务代码中像普通变量一样读写，即可自动完成持久化！
if YQSUISettings.isFirstLaunch {
    print("应用首次启动")
    YQSUISettings.isFirstLaunch = false
}

// 保存对象
YQSUISettings.userInfo = UserInfoModel(id: "123", name: "yumumu", avatar: nil)

// 读取对象
if let name = YQSUISettings.userInfo?.name {
    print("当前登录用户: \(name)")
}

// 清除对象
YQSUISettings.userInfo = nil

注意事项与建议

- `UserDefaults` 并不适合存储极大数据（如大体积 JSON、图片数据）或高敏感数据（如密码，应该用 `Keychain`）。
- 对于经常更新且数据量大的场景，推荐使用 `CoreData`、`Realm` 或 `SQLite`，该工具定位于“轻量级”和“配置级”存储。

作者: yumumu
文件: YQSUIStorageUtil.swift
