//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 统一日志记录工具（分级/线程/位置/可选文件落盘）
🎯 6A阶段: Approve
*/

import Foundation

// region Log Level
public enum YQSUILogLevel: Int, CaseIterable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    
    public var name: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
    
    public var icon: String {
        switch self {
        case .verbose: return "💬"
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    public var coloredPrefix: String {
        switch self {
        case .verbose: return "🔵 [VERBOSE] 💬"
        case .debug: return "� [DEBUG] 🐛"
        case .info: return "⚪ [INFO] ℹ️"
        case .warning: return "🟡 [WARNING] ⚠️"
        case .error: return "🔴 [ERROR] ❌"
        }
    }
}
// endregion

// region Configuration
public struct YQSUILogConfiguration {
    public var minLevel: YQSUILogLevel = .verbose
    public var showTimestamp: Bool = true
    public var showLocation: Bool = false
    public var showThread: Bool = false
    public var writeToFile: Bool = false
    public var logFilePath: String? = nil
    public var maxFileSize: Int = 10
    public var enableColor: Bool = true
    
    public init() {}
}
// endregion

// region Manager
public final class YQSUILogManager {
    public static let shared = YQSUILogManager()
    
    private let queue = DispatchQueue(label: "com.yqsui.log", qos: .utility)
    private let dateFormatter: DateFormatter
    private var configuration: YQSUILogConfiguration
    private var logFileHandle: FileHandle?
    
    public init(configuration: YQSUILogConfiguration = YQSUILogConfiguration()) {
        self.configuration = configuration
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = Locale(identifier: "zh_CN")
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        if configuration.writeToFile {
            setupLogFile()
        }
    }
    
    public func updateConfiguration(_ configuration: YQSUILogConfiguration) {
        queue.async {
            self.configuration = configuration
            self.logFileHandle?.closeFile()
            self.logFileHandle = nil
            
            if configuration.writeToFile {
                self.setupLogFile()
            }
        }
    }
    
    public func verbose(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .verbose, file: file, function: function, line: line)
    }
    
    public func debug(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    public func info(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    public func warning(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    public func error(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    public func clearLogFile() {
        queue.async {
            self.logFileHandle?.truncateFile(atOffset: 0)
            self.logFileHandle?.seekToEndOfFile()
        }
    }
    
    public func close() {
        queue.async {
            self.logFileHandle?.closeFile()
            self.logFileHandle = nil
        }
    }
    
    private func log(_ message: Any, level: YQSUILogLevel, file: String, function: String, line: Int) {
        guard level.rawValue >= configuration.minLevel.rawValue else { return }
        
        let logString = buildLogString(
            message: String(describing: message),
            level: level,
            file: file,
            function: function,
            line: line
        )
        
        queue.async {
            print(logString)
            if self.configuration.writeToFile {
                self.writeToFile(logString)
            }
        }
    }
    
    private func buildLogString(message: String, level: YQSUILogLevel, file: String, function: String, line: Int) -> String {
        var components: [String] = []
        
        if configuration.enableColor {
            components.append(level.coloredPrefix)
        } else {
            components.append("[\(level.name)]")
            components.append(level.icon)
        }
        
        if configuration.showTimestamp {
            let timestamp = dateFormatter.string(from: Date())
            components.append("[\(timestamp)]")
        }
        
        if configuration.showThread {
            let threadName = Thread.current.isMainThread ? "Main" : "Background"
            components.append("[\(threadName)]")
        }
        
        if configuration.showLocation {
            let fileName = (file as NSString).lastPathComponent
            components.append("[\(fileName):\(line)]")
            components.append(function)
        }
        
        components.append(message)
        return components.joined(separator: " ")
    }
    
    private func setupLogFile() {
        let filePath = configuration.logFilePath ?? defaultLogFilePath()
        let directory = (filePath as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        
        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            fileHandle.seekToEndOfFile()
            self.logFileHandle = fileHandle
        }
    }
    
    private func defaultLogFilePath() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("logs/app.log").path
    }
    
    private func writeToFile(_ logString: String) {
        guard let fileHandle = logFileHandle else { return }
        checkFileSize()
        guard let data = (logString + "\n").data(using: .utf8) else { return }
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
    }
    
    private func checkFileSize() {
        let filePath = configuration.logFilePath ?? defaultLogFilePath()
        guard
            let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
            let fileSize = attributes[.size] as? NSNumber
        else { return }
        
        let maxSize = configuration.maxFileSize * 1024 * 1024
        if fileSize.intValue > maxSize {
            logFileHandle?.truncateFile(atOffset: 0)
            logFileHandle?.seekToEndOfFile()
        }
    }
}
// endregion

// region Convenience
public func LogVerbose(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    YQSUILogManager.shared.verbose(message, file: file, function: function, line: line)
}

public func LogDebug(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    YQSUILogManager.shared.debug(message, file: file, function: function, line: line)
}

public func LogInfo(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    YQSUILogManager.shared.info(message, file: file, function: function, line: line)
}

public func LogWarning(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    YQSUILogManager.shared.warning(message, file: file, function: function, line: line)
}

public func LogError(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    YQSUILogManager.shared.error(message, file: file, function: function, line: line)
}
// endregion
