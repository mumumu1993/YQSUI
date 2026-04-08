YQSUI — Color 扩展 (YQSUIColor.swift)

简介

YQSUIColor.swift 为 SwiftUI 的 Color 提供了一组方便的初始化方法，允许通过十六进制数值、十六进制字符串或 0-255 范围的 RGB 整数直接创建颜色实例，并包含若干预设颜色。

可用性

- 依赖: SwiftUI
- 可用平台: iOS 13.0 及以上

API 概览

- init(hex: UInt, alpha: CGFloat = 1.0)
  - 通过 0xRRGGBB 格式的十六进制数值创建颜色。
  - 参数:
    - hex: 无符号整型，格式为 0xRRGGBB，例如 0x007AFF。
    - alpha: 透明度 (CGFloat)，默认为 1.0。

- init(hexString: String, alpha: CGFloat = 1.0)
  - 通过字符串形式的十六进制颜色创建颜色，支持 "#RRGGBB" 或 "RRGGBB" 格式。
  - 当输入无效（长度不为 6 或无法解析为 16 进制数）时，会返回透明色（Color.clear）。

- init(red: UInt8, green: UInt8, blue: UInt8, alpha: CGFloat = 1.0)
  - 通过 0~255 的 RGB 整数值创建颜色。
  - 参数类型为 UInt8，通常直接传入整数字面量即可。

- static let yqsBlue
  - 预设颜色，等同于 Color(hex: 0x007AFF)

使用示例（Swift）

```swift
import SwiftUI

// 使用十六进制数值
let c1 = Color(hex: 0xFF0000) // 红色

// 使用十六进制字符串
let c2 = Color(hexString: "#00FF00", alpha: 0.8) // 半透明绿色
let c3 = Color(hexString: "00FF00") // 绿色

// 使用 RGB 整数
let c4 = Color(red: 255, green: 128, blue: 64)

// 使用预设颜色
let primary = Color.yqsBlue

// 在 SwiftUI 视图中使用
struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Rectangle().fill(Color(hex: 0x007AFF)).frame(height: 44)
            Text("Hello").foregroundColor(Color.yqsBlue)
        }
        .padding()
    }
}
```

注意事项

- `init(hexString:alpha:)` 对输入严格要求 6 个十六进制字符（不含或含“#”均可）。无效输入将返回 `Color.clear`，以避免运行时崩溃。
- alpha 参数类型使用 `CGFloat`，在 SwiftUI 中常见的透明度值可直接传入（例如 0.0 到 1.0）。
- 由于这是对 SwiftUI 的 `Color` 的扩展，如果需要在 UIKit 中使用等价颜色，请使用 `UIColor` 的初始化方法或在需要时将 `Color` 转换为 `UIColor`（注意转换方式依赖使用场景和平台 API）。

贡献与许可证

欢迎 issue/PR 修正或扩展更多便捷方法（例如支持 ARGB、RGBA 十六进制或带字母大小写宽容的输入等）。

作者: yumumu
文件: YQSUIColor.swift
