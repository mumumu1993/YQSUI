//
//  YQSUIColor.swift
//  YQSUI
//
//  Created by yumumu on 2026/3/3.
//
import SwiftUI

public extension Color {
    /// 通过十六进制数值初始化颜色
    ///  - Parameters:
    ///   - hex: 0xRRGGBB 格式的十六进制颜色值
    ///   - alpha: 透明度，默认为 1.0	
    init(hex: UInt, alpha: CGFloat = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    /// 通过十六进制字符串初始化颜色
    ///  - Parameters:
    ///   - hexString: "#RRGGBB" 或 "RRGGBB" 格式的十六进制颜色字符串
    ///   - alpha: 透明度，默认为 1.0
    init(hexString: String, alpha: CGFloat = 1.0) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        guard hex.count == 6, let hexValue = UInt(hex, radix: 16) else {
            self.init(.clear) // 无效输入返回透明色
            return
        }
        self.init(hex: hexValue, alpha: alpha)
    }
    
    /// 通过 RGB 数值初始化颜色
    ///  - Parameters:
    ///   - red: 红色分量，0~255
    ///   - green: 绿色分量，0~255
    ///   - blue: 蓝色分量，0~255
    ///   - alpha: 透明度，默认为 1.0
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: CGFloat = 1.0) {
        self.init(red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0, opacity: alpha)
    }
    
    /// 预设颜色 0x007AFF
    static let yqsBlue = Color(hex: 0x007AFF)
}
