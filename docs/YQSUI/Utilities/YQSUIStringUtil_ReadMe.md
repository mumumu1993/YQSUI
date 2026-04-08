YQSUI — 字符串处理与验证 (YQSUIStringUtil.swift)

简介

`YQSUIStringUtil.swift` 提供了一套为 `String` 扩展的常用工具，用于数据加密、编码以及格式验证。基于苹果最新的 `CryptoKit`，该工具安全且高效地提供了 MD5 等哈希操作，并涵盖了日常开发中必需的手机号、邮箱等正则表达式校验。

主要能力

- 安全哈希与编码：MD5 (`CryptoKit`)、Base64 编解码、URL 编解码。
- 格式验证（正则表达式）：大陆手机号验证、通用邮箱格式验证。
- 所有扩展均遵循 `yqs_` 前缀规范，确保命名空间的安全。

API 概览

- String 扩展:
  - 加密/编码:
    - var yqs_md5: String
    - var yqs_base64Encoded: String?
    - var yqs_base64Decoded: String?
    - var yqs_urlEncoded: String?
    - var yqs_urlDecoded: String?
  - 正则验证:
    - var yqs_isValidPhone: Bool（匹配 11 位大陆手机号）
    - var yqs_isValidEmail: Bool

使用示例

import Foundation

// 1. MD5 加密
let password = "mySecurePassword"
let md5Hash = password.yqs_md5
print("MD5: \(md5Hash)")

// 2. Base64 编码与解码
let originalString = "Hello, YQSUI!"
if let encoded = originalString.yqs_base64Encoded {
    print("Base64 Encoded: \(encoded)")
    
    if let decoded = encoded.yqs_base64Decoded {
        print("Base64 Decoded: \(decoded)")
    }
}

// 3. 正则验证
let phone = "13800138000"
let isValidPhone = phone.yqs_isValidPhone // true

let email = "test@example.com"
let isValidEmail = email.yqs_isValidEmail // true

注意事项与建议

- `yqs_md5` 使用了 `CryptoKit` 下的 `Insecure.MD5`。对于涉及高安全性要求的场景（如存储关键密钥），建议升级使用 `SHA256` 及其以上算法。
- URL 编解码默认使用了 `.urlQueryAllowed` 字符集，这能覆盖绝大多数 GET 请求传参的需求。

作者: yumumu
文件: YQSUIStringUtil.swift
