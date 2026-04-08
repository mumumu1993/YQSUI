YQSUI — 防抖与节流 (YQSUIDebounce.swift)

简介

`YQSUIDebounce.swift` 提供了一套基于 GCD（Grand Central Dispatch）的防抖（Debounce）和节流（Throttle）闭包工具。在移动端开发中，经常遇到按钮防连点、搜索框防高频请求的场景，这套工具能够极大简化这类逻辑的编写，并确保闭包的安全派发。

主要能力

- 防抖（Debounce）：在指定延迟时间后执行，若延迟时间内重复触发，则重新计时（只执行最后一次触发）。
- 节流（Throttle）：在指定时间间隔内，无论触发多少次，仅执行第一次（适用于防止按钮连点）。
- 提供了可配置的派发队列（默认主队列）。

API 概览

- YQSUITimer: 静态方法工具类
  - static func debounce(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping () -> Void) -> () -> Void
  - static func throttle(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping () -> Void) -> () -> Void

使用示例

import Foundation

// 1. 防抖（搜索框输入，用户停止输入 0.5s 后执行请求）
class SearchViewModel {
    private lazy var performSearch: () -> Void = YQSUITimer.debounce(delay: 0.5) { [weak self] in
        self?.executeNetworkRequest()
    }
    
    func userDidInput(text: String) {
        // 用户每输入一个字符，调用一次 performSearch，
        // 实际上只有在用户停止输入 0.5s 后，才会真正执行 executeNetworkRequest()。
        self.performSearch()
    }
    
    private func executeNetworkRequest() {
        print("执行搜索网络请求...")
    }
}

// 2. 节流（按钮防连点，1s 内无论点击多少次只执行第一次）
class SubmitButtonHandler {
    private lazy var handleSubmit: () -> Void = YQSUITimer.throttle(delay: 1.0) { [weak self] in
        self?.processSubmit()
    }
    
    func buttonTapped() {
        // 快速点击时，1s 内只会触发一次 processSubmit()
        self.handleSubmit()
    }
    
    private func processSubmit() {
        print("提交表单...")
    }
}

注意事项与建议

- `debounce` 和 `throttle` 方法都返回一个无参闭包 `() -> Void`，您需要将其保存在实例属性中（如 `lazy var` 或属性中），并在事件发生时调用这个保存的闭包，而不能在每次事件发生时重新生成闭包。
- 默认情况下闭包在主队列（`.main`）执行，如果在异步场景下进行耗时操作，可以通过参数指定后台 `queue`。

作者: yumumu
文件: YQSUIDebounce.swift
