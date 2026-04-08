//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-03 12:00:00
🧠 AI服务/模型: Gemini-3.1-Pro-Preview
🤖 生成智能体: structured-code-generator
📝 生成范围: 缺省页/占位图
🎯 6A阶段: Approve
*/

import SwiftUI

// MARK: - Empty View Configuration
public struct YQSUIEmptyConfig {
    public var imageName: String?
    public var systemImageName: String?
    public var title: String
    public var description: String?
    public var buttonTitle: String?
    public var action: (() -> Void)?
    
    public init(
        imageName: String? = nil,
        systemImageName: String? = "tray",
        title: String = "暂无数据",
        description: String? = nil,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.imageName = imageName
        self.systemImageName = systemImageName
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.action = action
    }
}

// MARK: - Main Empty View
public struct YQSUIEmptyView: View {
    private let config: YQSUIEmptyConfig
    
    // 📍 构造器
    public init(config: YQSUIEmptyConfig) {
        self.config = config
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // 📍 占位图区域
            if let imageName = config.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            } else if let systemImageName = config.systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            // 📍 标题文本
            Text(config.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            // 📍 描述文本
            if let description = config.description {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // 📍 交互按钮
            if let buttonTitle = config.buttonTitle, let action = config.action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Previews (For Debugging)
#if DEBUG
struct YQSUIEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        YQSUIEmptyView(config: YQSUIEmptyConfig(
            systemImageName: "wifi.slash",
            title: "网络未连接",
            description: "请检查您的网络设置后重试",
            buttonTitle: "刷新",
            action: { print("点击刷新") }
        ))
    }
}
#endif
