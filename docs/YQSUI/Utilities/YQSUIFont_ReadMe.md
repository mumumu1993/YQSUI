YQSUI — 字体管理工具 (YQSUIFont.swift)

简介

`YQSUIFont.swift` 是一个旨在规范和统一全局应用字体使用的工具。它为 SwiftUI 的 `Font` 和 UIKit 的 `UIFont` 均提供了统一的系统与自定义字体初始化扩展，支持了动态字体大小（Dynamic Type），从而极大地提升了应用字体的可维护性和一致性。

主要能力

- `Font` 与 `UIFont` 扩展，提供统一的 `yqs_system` 与 `yqs_custom` 方法。
- 动态字体适配，在支持的 iOS 版本上提供了 `yqs_dynamic` 扩展（基于 SwiftUI）。
- 内置的 `yqs_printAllFonts` 调试功能，一键打印所有可用系统与自定义字体家族，便于开发调试。

API 概览

- Font 扩展:
  - static func yqs_system(size: CGFloat, weight: Font.Weight, design: Font.Design) -> Font
  - static func yqs_custom(name: String, size: CGFloat) -> Font
  - static func yqs_dynamic(size: CGFloat, weight: Font.Weight, textStyle: Font.TextStyle) -> Font

- UIFont 扩展:
  - static func yqs_system(size: CGFloat, weight: UIFont.Weight) -> UIFont
  - static func yqs_custom(name: String, size: CGFloat) -> UIFont
  - static func yqs_printAllFonts() // (仅 DEBUG 模式生效)

使用示例

import SwiftUI
import UIKit

// 1. SwiftUI 字体设置
Text("这是一个标题")
    .font(.yqs_system(size: 20, weight: .bold))

Text("这是一个自定义字体")
    .font(.yqs_custom(name: "PingFangSC-Regular", size: 16))

// 2. UIKit 字体设置
let label = UILabel()
label.font = .yqs_system(size: 14, weight: .medium)

// 3. 打印可用字体
#if DEBUG
UIFont.yqs_printAllFonts()
#endif

注意事项与建议

- `yqs_custom` 依赖于 `Info.plist` 中正确配置了对应的自定义字体文件（如 `.ttf` 或 `.otf`），并在 `UIAppFonts` 数组中声明。
- 动态字体 `yqs_dynamic` 依赖于 iOS 14.0+ 的特性，它可以在支持的系统下基于 `textStyle` 与基础字号，根据用户的偏好设置动态调整大小。

作者: yumumu
文件: YQSUIFont.swift
