//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 图片处理工具类
🎯 6A阶段: Approve
*/

import UIKit
import SwiftUI

// region Image Utilities
public extension UIImage {
    
    // 📍 通过颜色生成图片 (常用于背景图)
    static func yqs_image(with color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // 📍 调整图片大小 (缩放)
    func yqs_resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    // 📍 压缩图片质量到指定大小 (单位: KB)
    func yqs_compress(toMaxKB maxKB: Double) -> Data? {
        let maxBytes = maxKB * 1024
        var compression: CGFloat = 1.0
        guard var data = self.jpegData(compressionQuality: compression) else { return nil }
        
        if Double(data.count) < maxBytes { return data }
        
        var max: CGFloat = 1.0
        var min: CGFloat = 0.0
        
        // 二分法寻找合适的压缩率
        for _ in 0..<6 {
            compression = (max + min) / 2
            if let newData = self.jpegData(compressionQuality: compression) {
                data = newData
                if Double(data.count) < maxBytes {
                    min = compression
                } else if Double(data.count) > maxBytes {
                    max = compression
                } else {
                    break
                }
            }
        }
        
        // 如果依然大于指定大小，则进行尺寸缩小
        var resultImage: UIImage = self
        var lastDataCount: Int = 0
        while Double(data.count) > maxBytes && data.count != lastDataCount {
            lastDataCount = data.count
            let ratio: CGFloat = CGFloat(maxBytes) / CGFloat(data.count)
            let size: CGSize = CGSize(
                width: Int(resultImage.size.width * sqrt(ratio)),
                height: Int(resultImage.size.height * sqrt(ratio))
            )
            
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
                resultImage = resizedImage
                if let jpegData = resultImage.jpegData(compressionQuality: compression) {
                    data = jpegData
                }
            }
            UIGraphicsEndImageContext()
        }
        
        return data
    }
}
// endregion
