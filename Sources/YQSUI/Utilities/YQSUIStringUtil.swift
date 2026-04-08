//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 字符串处理与验证工具类
🎯 6A阶段: Approve
*/

import Foundation
import CryptoKit

// region String Utilities
public extension String {
    
    // 📍 MD5 加密
    var yqs_md5: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    // 📍 Base64 编码
    var yqs_base64Encoded: String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
    // 📍 Base64 解码
    var yqs_base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // 📍 URL 编码
    var yqs_urlEncoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    // 📍 URL 解码
    var yqs_urlDecoded: String? {
        return self.removingPercentEncoding
    }
    
    // 📍 验证是否是有效手机号 (大陆手机号)
    var yqs_isValidPhone: Bool {
        let pattern = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
    
    // 📍 验证是否是有效邮箱
    var yqs_isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
}
// endregion
