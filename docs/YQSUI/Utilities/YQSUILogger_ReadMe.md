YQSUI — 日志记录 (YQSUILogger.swift)

简介

`YQSUILogger.swift` 是一个用于替代原生 `print` 的统一日志工具，提供分级日志、可配置的输出格式（时间戳/线程/位置）、以及可选的文件落盘能力。默认输出带有 Emoji 前缀，便于在 Xcode 控制台快速定位不同级别的日志。

主要能力

- 分级日志：Verbose/Debug/Info/Warning/Error（支持最小输出级别过滤）。
- 输出可配置：是否显示时间戳、线程、文件与行号等信息。
- 可选写入文件：支持自定义路径、最大文件大小限制，超过后自动截断。
- 线程安全：日志构建与写文件在后台队列执行，避免阻塞主线程。

API 概览

- YQSUILogLevel: 日志级别枚举
  - verbose / debug / info / warning / error
  - name/icon/coloredPrefix：用于格式化输出

- YQSUILogConfiguration: 日志配置
  - minLevel: 最小输出级别（低于该级别不输出）
  - showTimestamp / showLocation / showThread: 输出内容开关
  - writeToFile / logFilePath / maxFileSize: 文件落盘配置
  - enableColor: 是否启用带 Emoji 的彩色前缀

- YQSUILogManager: 日志管理器（单例）
  - static let shared
  - func updateConfiguration(_:)
  - func verbose/debug/info/warning/error(_:)
  - func clearLogFile() / close()

- 便捷函数（全局）
  - LogVerbose / LogDebug / LogInfo / LogWarning / LogError

使用示例

1) 基础使用（推荐直接使用 manager）

import YQSUI

YQSUILogManager.shared.info("开始网络请求...")
YQSUILogManager.shared.error("网络请求失败: Timeout error.")

2) 使用全局便捷函数

import YQSUI

LogInfo("加载成功")
LogError("加载失败")

3) 更新配置（例如：只输出 Warning 及以上，并写入文件）

import YQSUI

var config = YQSUILogConfiguration()
config.minLevel = .warning
config.showTimestamp = true
config.showLocation = true
config.showThread = true
config.writeToFile = true
config.maxFileSize = 10
YQSUILogManager.shared.updateConfiguration(config)

注意事项与建议

- 如果你希望 Release 环境默认不输出日志，可以在 App 启动时根据编译环境或运行环境调整 `minLevel`，或关闭 `writeToFile`。
- 若开启写文件，默认路径为 Document/logs/app.log；也可以通过 `logFilePath` 指定自定义路径。
- `showLocation` 会增加一定的字符串拼接开销，建议仅在排查问题时开启。

作者: yumumu
文件: YQSUILogger.swift
