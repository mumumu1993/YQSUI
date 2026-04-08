YQSUI — 沙盒文件管理 (YQSUIFileUtil.swift)

简介

`YQSUIFileUtil.swift` 提供了一组访问和操作应用沙盒目录（Document, Cache, Temp）的快捷工具。通过这个工具类，您可以轻松获取常见路径，计算本地文件或整个缓存文件夹的体积（MB/Byte），并提供了一键清除所有缓存数据的简便方法。

主要能力

- 快捷访问 `documentPath`、`cachePath` 和 `tempPath`。
- 获取指定路径的单个文件大小（`fileSize`）和整个文件夹大小（`folderSize`）。
- 提供安全的文件夹内容清理（`clearFolder`）和一键清理所有缓存（`clearAllCaches`）操作。

API 概览

- YQSUIFileUtil: 文件管理工具结构体
  - static var documentPath: String
  - static var cachePath: String
  - static var tempPath: String
  - static func fileSize(at path: String) -> UInt64
  - static func folderSize(at path: String) -> Double
  - static func clearFolder(at path: String)
  - static func clearAllCaches()

使用示例

import Foundation

// 1. 获取常见路径
let cacheDir = YQSUIFileUtil.cachePath
print("Cache 目录路径: \(cacheDir)")

// 2. 获取缓存文件夹大小（常用于设置页面展示“清理缓存”功能）
let sizeInMB = YQSUIFileUtil.folderSize(at: cacheDir)
print("当前缓存大小为: \(String(format: "%.2f", sizeInMB)) MB")

// 3. 一键清理所有缓存
YQSUIFileUtil.clearAllCaches()

注意事项与建议

- `clearAllCaches()` 仅清理 `Caches` 和 `tmp` 目录下的内容，不触及 `Documents`，因此对于重要数据（如用户配置、离线下载的文件）建议始终存储在 `Documents` 目录下。
- 文件大小和文件夹大小的获取涉及 IO 操作，对于极大量的文件（如图片缓存），可能会导致轻微的阻塞，建议在主线程外调用 `folderSize` 并在主线程更新 UI。

作者: yumumu
文件: YQSUIFileUtil.swift
