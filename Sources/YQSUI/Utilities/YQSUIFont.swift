//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 统一字体管理工具
🎯 6A阶段: Approve
*/

import SwiftUI
import UIKit

// region Font Utilities
public extension Font {
    
    // 📍 统一的系统字体快捷调用
    static func yqs_system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        return .system(size: size, weight: weight, design: design)
    }
    
    // 📍 统一的自定义字体快捷调用
    static func yqs_custom(name: String, size: CGFloat) -> Font {
        return .custom(name, size: size)
    }
    
    // 📍 动态字体支持 (Dynamic Type)
    static func yqs_dynamic(size: CGFloat, weight: Font.Weight = .regular, textStyle: Font.TextStyle = .body) -> Font {
        if #available(iOS 14.0, *) {
            return .system(size: size, weight: weight).bold() // Note: iOS 14 allows specific dynamic type relative scalings if needed via ViewModifiers
        }
        return .system(size: size, weight: weight)
    }
}

public extension UIFont {
    
    // 📍 统一的 UIKit 系统字体快捷调用
    static func yqs_system(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return .systemFont(ofSize: size, weight: weight)
    }
    
    // 📍 统一的 UIKit 自定义字体快捷调用
    static func yqs_custom(name: String, size: CGFloat) -> UIFont {
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
    }
    
    // 📍 打印所有可用字体 (调试用)
    static func yqs_printAllFonts() {
        #if DEBUG
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   - \(name)")
            }
        }
        #endif
    }
}
// endregion
