//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 沙盒文件管理工具类
🎯 6A阶段: Approve
*/

import Foundation

// region File Utilities
public struct YQSUIFileUtil {
    
    // 📍 沙盒常用路径获取
    public static var documentPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }
    
    public static var cachePath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
    }
    
    public static var tempPath: String {
        return NSTemporaryDirectory()
    }
    
    // 📍 获取单个文件大小 (单位: Byte)
    public static func fileSize(at path: String) -> UInt64 {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: path)
                return attributes[.size] as? UInt64 ?? 0
            } catch {
                LogError("获取文件大小失败: \(error)")
                return 0
            }
        }
        return 0
    }
    
    // 📍 获取文件夹大小 (单位: MB)
    public static func folderSize(at path: String) -> Double {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else { return 0 }
        
        var totalSize: UInt64 = 0
        if let enumerator = fileManager.enumerator(atPath: path) {
            for file in enumerator {
                if let fileName = file as? String {
                    let fullPath = (path as NSString).appendingPathComponent(fileName)
                    totalSize += fileSize(at: fullPath)
                }
            }
        }
        return Double(totalSize) / (1024.0 * 1024.0)
    }
    
    // 📍 清除指定文件夹下的所有文件
    public static func clearFolder(at path: String) {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: path)
            for file in files {
                let fullPath = (path as NSString).appendingPathComponent(file)
                try fileManager.removeItem(atPath: fullPath)
            }
        } catch {
            LogError("清除文件夹内容失败: \(error)")
        }
    }
    
    // 📍 一键清除沙盒缓存 (Cache & Temp)
    public static func clearAllCaches() {
        clearFolder(at: cachePath)
        clearFolder(at: tempPath)
    }
}
// endregion
