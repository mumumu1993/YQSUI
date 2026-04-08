YQSUI — 设备与应用信息 (YQSUIDeviceUtil.swift)

简介

`YQSUIDeviceUtil.swift` 提供了一个便捷获取当前设备和应用运行信息的工具类。通过统一的 API 封装，使得获取应用的 `Version`、`Build` 号、`Bundle ID` 以及设备的硬件型号（如 `iPhone13,2`）变得非常简单。同时提供了检测当前运行环境是否为模拟器的实用方法。

主要能力

- 统一获取应用基本信息（版本号、构建号、包名）。
- 快捷获取设备系统版本。
- 获取设备的具体硬件标识（Identifier，例如 `"iPhone12,1"`）。
- 检测应用当前是否在 Simulator (模拟器) 环境下运行。

API 概览

- YQSUIDevice: 设备与应用信息结构体
  - static var appVersion: String
  - static var buildVersion: String
  - static var systemVersion: String
  - static var bundleIdentifier: String
  - static var model: String
  - static var isSimulator: Bool

使用示例

import Foundation

// 1. 应用信息
let version = YQSUIDevice.appVersion // "1.0.0"
let build = YQSUIDevice.buildVersion // "1"
let bundleId = YQSUIDevice.bundleIdentifier // "com.example.app"

// 2. 硬件与系统信息
let osVersion = YQSUIDevice.systemVersion // "17.0"
let deviceModel = YQSUIDevice.model // "iPhone14,2" (即 iPhone 13 Pro)

// 3. 模拟器检测（常用于屏蔽不支持模拟器的功能）
if YQSUIDevice.isSimulator {
    print("运行在模拟器上，跳过某些功能初始化...")
}

注意事项与建议

- `model` 属性返回的是硬件的原始内部标识（如 `"iPhone13,2"`，代表 iPhone 12），如果您需要展示给用户“友好的名称”，可以在外层进行进一步的映射转换。
- `isSimulator` 利用了 `#if targetEnvironment(simulator)` 编译指令，能够确保判断的准确性，非常适合用于在代码中动态关闭模拟器不支持的功能（例如某些相机和推送的测试）。

作者: yumumu
文件: YQSUIDeviceUtil.swift
