YQSUI — 系统权限管理 (YQSUIPermissionUtil.swift)

简介

`YQSUIPermissionUtil.swift` 提供了一组标准化的方法来检查和请求 iOS 的各项核心权限。该工具涵盖了应用开发中最常见的权限类型，如：相机、麦克风、相册、推送通知等，极大地简化了重复且繁琐的权限判断代码，并支持一键引导用户打开系统设置。

主要能力

- 统一的权限检查和请求接口，利用闭包返回布尔值。
- 支持 `requestCamera`, `requestMicrophone`, `requestPhotoLibrary`, `requestNotification`。
- 提供 `openSystemSettings()` 方法，方便在用户拒绝后引导跳转。

API 概览

- YQSUIPermissionUtil: 权限管理工具结构体
  - static func requestCamera(completion: @escaping (Bool) -> Void)
  - static func requestMicrophone(completion: @escaping (Bool) -> Void)
  - static func requestPhotoLibrary(completion: @escaping (Bool) -> Void)
  - static func requestNotification(completion: @escaping (Bool) -> Void)
  - static func openSystemSettings()

使用示例

import AVFoundation
import Photos
import UserNotifications

// 1. 检查和请求相机权限
YQSUIPermissionUtil.requestCamera { granted in
    if granted {
        // 用户已授权，进入相机页面
        print("Camera access granted")
    } else {
        // 权限被拒绝或未决定，引导跳转设置
        print("Camera access denied")
        YQSUIPermissionUtil.openSystemSettings()
    }
}

// 2. 检查和请求相册权限
YQSUIPermissionUtil.requestPhotoLibrary { granted in
    if granted {
        print("Photo library access granted")
    } else {
        print("Photo library access denied")
    }
}

注意事项与建议

- `completion` 闭包中的回调默认已经派发到主线程，您可以直接在闭包内更新 UI，无需再次调用 `DispatchQueue.main.async`。
- 确保在应用的 `Info.plist` 中添加了对应的权限描述字段（例如 `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, `NSPhotoLibraryUsageDescription` 等），否则应用会在请求权限时直接崩溃。

作者: yumumu
文件: YQSUIPermissionUtil.swift
