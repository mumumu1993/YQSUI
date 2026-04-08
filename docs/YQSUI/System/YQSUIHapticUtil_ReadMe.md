YQSUI — 触觉反馈 (YQSUIHapticUtil.swift)

简介

`YQSUIHapticUtil.swift` 封装了 iOS 中 `UIFeedbackGenerator` 家族的核心功能，提供了一套方便、直观的触觉（Haptic）反馈工具类。无论是在按钮按下、系统弹窗还是在滑动选择时，这套工具都能让您仅用一行代码即刻实现细腻的设备震动反馈体验。

主要能力

- 对 `UINotificationFeedbackGenerator` 封装了状态反馈：成功、警告、错误。
- 对 `UIImpactFeedbackGenerator` 封装了物理冲击反馈：轻度、中度、重度。
- 对 `UISelectionFeedbackGenerator` 封装了选择反馈（类似于滚动 Picker 时）。

API 概览

- YQSUIHaptic: 触觉反馈静态工具类
  - static func success() (通知：成功)
  - static func warning() (通知：警告)
  - static func error() (通知：错误)
  - static func light() (冲击：轻量)
  - static func medium() (冲击：中量)
  - static func heavy() (冲击：重量)
  - static func selection() (选择变化)

使用示例

import UIKit

class ExampleViewController: UIViewController {
    
    // 1. 成功反馈（例如支付成功、加载完成）
    func onPaymentSuccess() {
        YQSUIHaptic.success()
        print("支付成功")
    }
    
    // 2. 警告反馈（例如密码错误、输入不合法）
    func onInputError() {
        YQSUIHaptic.error()
        print("输入有误")
    }
    
    // 3. 轻量冲击反馈（例如点击某个非关键按钮）
    @IBAction func lightButtonTapped(_ sender: UIButton) {
        YQSUIHaptic.light()
    }
    
    // 4. 选择变化反馈（例如滑动列表或选择器时）
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        YQSUIHaptic.selection()
    }
}

注意事项与建议

- `UIFeedbackGenerator` 在较老的设备（iPhone 6s 之前）上并不受硬件 Taptic Engine 的支持，但在这些设备上调用并不会引发错误，它会自动回退或静默忽略。
- 频繁且连续调用震动反馈（如长列表的高频滚动）应该使用 `UISelectionFeedbackGenerator` 并由系统控制准备与触发机制，如果手动过于频繁调用可能会导致 Taptic Engine 延迟或发热。

作者: yumumu
文件: YQSUIHapticUtil.swift
