YQSUI — 图片处理工具 (YQSUIImageUtil.swift)

简介

`YQSUIImageUtil.swift` 为 `UIImage` 提供了一系列极为实用的扩展方法，涵盖了从颜色生成纯色图片到图片缩放、以及最常见的“按目标文件大小（KB）压缩图片”功能。这对于涉及图片上传（如头像、相册选择）的业务场景尤为重要。

主要能力

- 基于 `UIColor` 生成指定尺寸的纯色图片。
- 等比例或指定尺寸对图片进行缩放 (`yqs_resized`)。
- 使用二分法结合尺寸调整，将图片精确压缩到指定的最大 KB 数以内 (`yqs_compress`)。

API 概览

- UIImage 扩展:
  - static func yqs_image(with color: UIColor, size: CGSize) -> UIImage?
  - func yqs_resized(to size: CGSize) -> UIImage?
  - func yqs_compress(toMaxKB maxKB: Double) -> Data?

使用示例

import UIKit

// 1. 生成纯色图片（常用于按钮背景状态）
let blueImage = UIImage.yqs_image(with: .blue, size: CGSize(width: 1, height: 1))
let button = UIButton()
button.setBackgroundImage(blueImage, for: .normal)

// 2. 缩放图片
let originalImage = UIImage(named: "avatar")
let thumbnailImage = originalImage?.yqs_resized(to: CGSize(width: 100, height: 100))

// 3. 压缩图片至指定 KB (例如微信分享限制 32KB)
let maxKB: Double = 32.0
if let compressedData = originalImage?.yqs_compress(toMaxKB: maxKB) {
    print("压缩后的大小: \(Double(compressedData.count) / 1024.0) KB")
    let finalImage = UIImage(data: compressedData)
}

注意事项与建议

- `yqs_compress` 方法使用了二分法查找最优的 `compressionQuality`，如果仅调整质量无法满足要求（如图片尺寸过大），它会进一步自动缩小图片分辨率，直到数据大小满足 `maxKB` 限制。
- 这些方法使用了 `UIGraphicsBeginImageContextWithOptions` 及其相关 API，在频繁调用或处理极大图片时，请注意放到后台线程执行以防阻塞主线程。

作者: yumumu
文件: YQSUIImageUtil.swift
