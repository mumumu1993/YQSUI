YQSUI — 安全定时器 (YQSUITimerUtil.swift)

简介

`YQSUITimerUtil.swift` 提供了一个安全、轻量级、无循环引用风险的定时器工具，基于底层 GCD 的 `DispatchSourceTimer`。与 Foundation 框架中的 `Timer` 相比，它不需要依赖 `RunLoop`（所以在滑动列表时也不会暂停），同时避免了 `Timer` 常见的目标（Target）强引用而导致内存泄漏的问题。

主要能力

- 基于 `DispatchQueue` 和 `DispatchSourceTimer`，提供毫秒级的执行精度。
- 支持单次延时执行（`repeats: false`）和循环执行（`repeats: true`）。
- 通过字符串标识符（`name`）全局管理定时器任务，可以随时启动、查询、取消。
- 内置了线程安全的锁（`NSLock`）来保证并发情况下的安全操作。

API 概览

- YQSUITimerUtil: 定时器静态工具类
  - static func start(name: String, timeInterval: TimeInterval, repeats: Bool, queue: DispatchQueue, action: @escaping () -> Void) -> String
  - static func cancel(name: String)
  - static func cancelAll()
  - static func isRunning(name: String) -> Bool

使用示例

import Foundation

// 1. 启动一个持续执行的定时任务
let timerName = YQSUITimerUtil.start(name: "my_timer", timeInterval: 1.0, repeats: true) {
    print("定时器执行中...")
}

// 2. 检查定时器是否正在运行
if YQSUITimerUtil.isRunning(name: "my_timer") {
    print("定时器正在运行！")
}

// 3. 取消指定的定时器
YQSUITimerUtil.cancel(name: "my_timer")
print("定时器已取消")

// 4. 启动一个单次延迟任务（例如 2 秒后执行）
YQSUITimerUtil.start(timeInterval: 2.0, repeats: false) {
    print("延迟 2 秒执行")
}

// 5. 在对象被销毁时取消所有关联的定时器
deinit {
    YQSUITimerUtil.cancelAll()
    print("控制器已销毁，定时器被清理")
}

注意事项与建议

- `name` 参数是可选的。如果不传入 `name`，工具会自动生成一个 UUID 并作为返回值返回，您可以使用该返回值来取消任务。如果传入的 `name` 已经存在，新任务会覆盖并取消旧任务。
- 闭包 `action` 默认在主线程（`.main` queue）中回调，这方便了大多数的 UI 更新。如果您需要在后台线程执行耗时任务，只需在调用 `start` 时指定自定义的 `queue` 即可。

作者: yumumu
文件: YQSUITimerUtil.swift
