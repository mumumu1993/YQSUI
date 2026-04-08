YQSUI — 键盘监听与避让 (YQSUIKeyboardUtil.swift)

简介

`YQSUIKeyboardUtil.swift` 提供了一个用于监听系统键盘弹出与收起的单例工具，以及一个基于 SwiftUI `ViewModifier` 实现的自动避让修饰符。该工具能够解决在某些复杂的输入场景下，原生 SwiftUI 或 UIKit 无法完美自动抬高视图以避免被键盘遮挡的问题。

主要能力

- 基于 `Combine` 和 `NotificationCenter` 实时监听系统键盘的 `.keyboardWillShow` 和 `.keyboardWillHide` 通知，并将高度发布为 `@Published` 属性。
- 提供修饰符 `.yqs_keyboardAdaptive()` 方便给包含 TextField 的页面自动上推（Padding）以避让键盘。
- 提供全局收起键盘的快捷方法 `yqs_hideKeyboard()`。

API 概览

- YQSUIKeyboardUtil: 键盘监听管理器
  - static let shared: 单例实例
  - @Published public private(set) var keyboardHeight: CGFloat
  
- SwiftUI View 扩展:
  - func yqs_keyboardAdaptive() -> some View
  - func yqs_hideKeyboard()

使用示例

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("用户名", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("密码", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("登录") {
                // 点击登录时自动收起键盘
                self.yqs_hideKeyboard()
            }
            .padding()
            
            Spacer()
        }
        // 当键盘弹出时，整个视图底部自动增加与键盘等高的 Padding，以实现避让
        .yqs_keyboardAdaptive()
        // 点击空白处收起键盘
        .onTapGesture {
            self.yqs_hideKeyboard()
        }
    }
}

注意事项与建议

- SwiftUI 原生的某些视图（如 List、Form）可能自带键盘避让功能，请根据实际场景决定是否需要使用 `.yqs_keyboardAdaptive()`，以防出现双倍避让或动画冲突。
- `yqs_hideKeyboard()` 是通过 `UIApplication.shared.sendAction` 机制实现的，它可以无需传入特定 `TextField` 即可全局让第一响应者（First Responder）失去焦点。

作者: yumumu
文件: YQSUIKeyboardUtil.swift
