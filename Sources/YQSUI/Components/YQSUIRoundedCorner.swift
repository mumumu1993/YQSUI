//
//  YQSUIRoundedCorner.swift
//  Project
//
//  Created by yumumu on 2026/1/12.
//  Copyright © 2026 Thread0. All rights reserved.
//

import SwiftUI

/// 支持“只对指定角做圆角”的 Shape。
///
/// SwiftUI 原生 `RoundedRectangle` 只能对所有角生效；当你只想圆左上/右上等特定角时，可使用该 Shape。
public struct YQSUIRoundedCorner: Shape {
    public var radius: CGFloat
    public var corners: UIRectCorner

    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let bezier = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(bezier.cgPath)
    }
}

/// 常用的 `UIRectCorner` 组合快捷值。
///
/// 用法：
/// `view.yqsUICornerRadius(12, corners: .topCorners)`
public enum YQSUIRectCorners {
    public static let allCorners: UIRectCorner = .allCorners
    public static let topCorners: UIRectCorner = [.topLeft, .topRight]
    public static let bottomCorners: UIRectCorner = [.bottomLeft, .bottomRight]
    public static let leftCorners: UIRectCorner = [.topLeft, .bottomLeft]
    public static let rightCorners: UIRectCorner = [.topRight, .bottomRight]
}

public extension View {
    /// 仅对指定角应用圆角（通过 `clipShape` 实现）。
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 需要圆角的角（如 `[.topLeft, .topRight]`）
    /// - Returns: 应用圆角后的视图
    func yqsUICornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(YQSUIRoundedCorner(radius: radius, corners: corners))
    }

    /// 仅对指定角裁剪成圆角矩形（语义上更明确）。
    ///
    /// 与 `yqsUICornerRadius` 等价，只是命名更偏“裁剪”。
    func yqsUIClipRoundedRect(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(YQSUIRoundedCorner(radius: radius, corners: corners))
    }

    /// 给“指定角圆角”的形状添加描边（边框）。
    ///
    /// 示例：
    /// ```swift
    /// Text("Hello")
    ///   .padding(12)
    ///   .yqsUIRoundedBorder(.blue, lineWidth: 1, cornerRadius: 12, corners: [.topLeft, .topRight])
    /// ```
    func yqsUIRoundedBorder(
        _ color: Color,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat,
        corners: UIRectCorner
    ) -> some View {
        overlay(
            YQSUIRoundedCorner(radius: cornerRadius, corners: corners)
                .stroke(color, lineWidth: lineWidth)
        )
    }

    /// 当你做了裁剪圆角但还想让点按区域保持矩形时，可额外加上这个。
    ///
    /// 这在 `List`/卡片等场景比较常见：视觉上是圆角，但交互区域希望是整块矩形。
    func yqsUIRectContentShape() -> some View {
        contentShape(Rectangle())
    }

    /// 对所有角应用圆角（默认）。
    ///
    /// 这是一个便捷重载：当你不关心具体角时，直接写 `.yqsUICornerRadius(12)`。
    func yqsUICornerRadius(_ radius: CGFloat) -> some View {
        yqsUICornerRadius(radius, corners: .allCorners)
    }

    /// 仅对顶部两个角应用圆角。
    func yqsUITopCornerRadius(_ radius: CGFloat) -> some View {
        yqsUICornerRadius(radius, corners: YQSUIRectCorners.topCorners)
    }

    /// 仅对底部两个角应用圆角。
    func yqsUIBottomCornerRadius(_ radius: CGFloat) -> some View {
        yqsUICornerRadius(radius, corners: YQSUIRectCorners.bottomCorners)
    }

    /// 给所有角添加圆角边框（默认）。
    func yqsUIRoundedBorder(
        _ color: Color,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat
    ) -> some View {
        yqsUIRoundedBorder(color, lineWidth: lineWidth, cornerRadius: cornerRadius, corners: .allCorners)
    }

    /// 给顶部两个角的圆角形状添加边框。
    func yqsUITopRoundedBorder(
        _ color: Color,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat
    ) -> some View {
        yqsUIRoundedBorder(
            color,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius,
            corners: YQSUIRectCorners.topCorners
        )
    }

    /// 给底部两个角的圆角形状添加边框。
    func yqsUIBottomRoundedBorder(
        _ color: Color,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat
    ) -> some View {
        yqsUIRoundedBorder(
            color,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius,
            corners: YQSUIRectCorners.bottomCorners
        )
    }
}
