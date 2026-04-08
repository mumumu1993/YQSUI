YQSUI — 日期与时间工具 (YQSUIDateUtil.swift)

简介

`YQSUIDateUtil.swift` 提供了常见且便捷的日期格式化、时间戳互相转换以及对原生 `Date` 类型的常用扩展方法。该工具致力于解决在网络请求数据和 UI 展示之间的各种时间转换操作，以及日常诸如“判断今天、昨天、今年”等时间戳业务需求。

主要能力

- `YQSUIDateUtil`: 提供日期和字符串、毫秒级时间戳、秒级时间戳之间的双向互转功能。
- `Date` 扩展: 增加 `yqs_isToday`, `yqs_isYesterday`, `yqs_isThisYear` 等常用的判断方法。

API 概览

- YQSUIDateUtil: 静态方法工具类
  - static func string(from date: Date, format: String): Date 转换为 String
  - static func date(from string: String, format: String): String 转换为 Date
  - static func string(fromTimestamp timestamp: TimeInterval, format: String): 秒级时间戳转换
  - static func string(fromMilliTimestamp timestamp: TimeInterval, format: String): 毫秒级时间戳转换

- Date 扩展:
  - var yqs_isToday: Bool
  - var yqs_isYesterday: Bool
  - var yqs_isThisYear: Bool

使用示例

import Foundation

// 1. 基础转换
let dateString = YQSUIDateUtil.string(from: Date(), format: "yyyy-MM-dd") // "2026-04-03"
let date = YQSUIDateUtil.date(from: "2026-04-03 12:00:00") // Date 对象

// 2. 时间戳转换
let timestamp: TimeInterval = 1775200000 // 秒
let timeStr = YQSUIDateUtil.string(fromTimestamp: timestamp) // "2026-04-03 12:26:40"

let milliTimestamp: TimeInterval = 1775200000000 // 毫秒
let milliTimeStr = YQSUIDateUtil.string(fromMilliTimestamp: milliTimestamp) // "2026-04-03 12:26:40"

// 3. 扩展判断
let today = Date()
if today.yqs_isToday {
    print("今天是: \(YQSUIDateUtil.string(from: today))")
}
if today.yqs_isThisYear {
    print("今年是: \(Calendar.current.component(.year, from: today))")
}

注意事项与建议

- 工具中默认的日期格式化字符串为 `"yyyy-MM-dd HH:mm:ss"`，可通过参数覆盖。
- 所有 `Date` 扩展方法统一以 `yqs_` 开头，避免与第三方库或原生方法发生命名冲突。
- 对于极端情况，建议手动配置 `DateFormatter` 的 `locale` 和 `timeZone`，该工具默认采用系统当前时区。

作者: yumumu
文件: YQSUIDateUtil.swift
