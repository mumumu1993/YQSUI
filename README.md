# YQSUI

轻量的 SwiftUI UI 组件与开发工具集合（iOS 14+），覆盖常用组件、工具方法与系统交互封装，适合在业务项目中作为基础包直接引入。

## 功能概览

- Components：颜色、圆角、对话框（含 UIKit overlay）、Toast、网络图片、Loading、EmptyView、BottomSheet、自定义导航栏等
- Utilities：屏幕/安全区、窗口与顶层 VC、日志、字体、图片处理、沙盒文件等
- System：权限、网络状态监听、键盘监听与避让、触觉反馈、防抖与节流等
- Data：UserDefaults 持久化封装、GCD 安全定时器等

## 文档索引

文档位于 `docs/YQSUI/`，按功能分类到不同文件夹，并提供索引页：

- [YQSUI 文档索引](docs/YQSUI/README.md)

## 安装（Swift Package Manager）

在 Xcode 中选择 Add Packages，输入仓库地址后添加依赖；或在 `Package.swift` 中添加：

```swift
.package(url: "<YOUR_REPO_URL>", from: "0.1.0")
```

然后在代码中使用：

```swift
import YQSUI
```

## 快速开始

SwiftUI Toast（吐司提示）：

```swift
import SwiftUI
import YQSUI

struct ContentView: View {
    private let toastManager = YQSUIToastManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Button("Show Toast") {
                YQSUIToastManager.showGlobal("操作成功", style: .success, position: .center)
            }
        }
        .yqsUIToast(toastManager)
    }
}
```

SwiftUI Dialog（对话框）：

```swift
import SwiftUI
import YQSUI

struct DemoDialogView: View {
    @StateObject private var dialogManager = YQSUIDialogManager()

    var body: some View {
        Button("Show Alert") {
            dialogManager.showAlert(title: "提示", message: "这是一个对话框")
        }
        .yqsUIDialog(dialogManager)
    }
}
```

作者: yumumu

有关详细实现与 API，请在 `docs/YQSUI/` 下打开对应的 ReadMe 文件。
