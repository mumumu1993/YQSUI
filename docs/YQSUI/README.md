# YQSUI 文档索引

本目录包含 YQSUI 库的模块级文档（中文），并按功能分类到不同文件夹。你可以从本索引页快速跳转到对应模块的完整文档。

目录

## Components

- [YQSUIColor — 颜色工具与便捷扩展](Components/YQSUIColor_ReadMe.md)
- [YQSUIRoundedCorner — 指定角圆角 Shape 与 View 扩展](Components/YQSUIRoundedCorner_ReadMe.md)
- [YQSUIDialog — 数据驱动的对话框组件与 UIKit 兼容层](Components/YQSUIDialog_ReadMe.md)
- [YQSUITips — 提示 / 吐司（Toast）组件](Components/YQSUITips_ReadMe.md)
- [YQSUIWebImage — 轻量 Web Image 与缓存](Components/YQSUIWebImage_ReadMe.md)
- [YQSUILoading — 全局加载 HUD](Components/YQSUILoading_ReadMe.md)
- [YQSUIEmptyView — 缺省页与占位图](Components/YQSUIEmptyView_ReadMe.md)
- [YQSUIBottomSheet — 底部半屏弹窗](Components/YQSUIBottomSheet_ReadMe.md)
- [YQSUINavigationBar — 自定义导航栏](Components/YQSUINavigationBar_ReadMe.md)

## Utilities

- [YQSUIUtil — 工具与通用扩展](Utilities/YQSUIUtil_ReadMe.md)
- [YQSUILogger — 日志记录](Utilities/YQSUILogger_ReadMe.md)
- [YQSUIFont — 字体管理工具](Utilities/YQSUIFont_ReadMe.md)
- [YQSUIImageUtil — 图片处理工具](Utilities/YQSUIImageUtil_ReadMe.md)
- [YQSUIFileUtil — 沙盒文件管理](Utilities/YQSUIFileUtil_ReadMe.md)
- [YQSUIDateUtil — 日期与时间工具](Utilities/YQSUIDateUtil_ReadMe.md)
- [YQSUIStringUtil — 字符串处理与验证](Utilities/YQSUIStringUtil_ReadMe.md)
- [YQSUIDeviceUtil — 设备与应用信息](Utilities/YQSUIDeviceUtil_ReadMe.md)

## System

- [YQSUIPermissionUtil — 系统权限管理](System/YQSUIPermissionUtil_ReadMe.md)
- [YQSUINetworkMonitor — 网络状态监听](System/YQSUINetworkMonitor_ReadMe.md)
- [YQSUIKeyboardUtil — 键盘监听与避让](System/YQSUIKeyboardUtil_ReadMe.md)
- [YQSUIHaptic — 触觉反馈](System/YQSUIHapticUtil_ReadMe.md)
- [YQSUIDebounce — 防抖与节流](System/YQSUIDebounce_ReadMe.md)

## Data

- [YQSUIStorageUtil — 持久化存储（UserDefaults 封装）](Data/YQSUIStorageUtil_ReadMe.md)
- [YQSUITimerUtil — 安全定时器（GCD 封装）](Data/YQSUITimerUtil_ReadMe.md)

快速使用提示

- 文档按模块组织，建议先阅读索引以快速定位需要的模块，再打开对应文档查看示例代码。
- 在 UI 测试中，建议为关键控件设置 `accessibilityIdentifier`（例如：`YQSUIDialogBackdrop`, `YQSUIDialogCard`, `showAlertButton` 等），提高测试稳定性。
- 若在 CI（GitHub Actions 等）中运行 UI tests，请查看 `.github/workflows/ci-ui-tests.yml`。

贡献与联系

如果你发现文档不完整或需要补充示例，欢迎提交 Issue 或 PR。作者：yumumu。
