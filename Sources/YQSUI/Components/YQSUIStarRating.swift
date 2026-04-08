//
/**
🤖 AI代码生成信息
⏱️ 生成时间: 2026-04-07 00:00:00
🧠 AI服务/模型: GPT-5.2
🤖 生成智能体: structured-code-generator
📝 生成范围: 星星打分控件（支持点击选择与滑动选择）
🎯 6A阶段: Automate
*/

import SwiftUI

// region Star Rating
public struct YQSUIStarRating: View {
    @Binding private var rating: Int
    private let maxRating: Int
    private let starSize: CGFloat
    private let spacing: CGFloat
    private let filledColor: Color
    private let emptyColor: Color
    private let filledSymbol: String
    private let emptySymbol: String
    private let isInteractive: Bool

    public init(
        rating: Binding<Int>,
        maxRating: Int = 5,
        starSize: CGFloat = 22,
        spacing: CGFloat = 6,
        filledColor: Color = .yellow,
        emptyColor: Color = .gray.opacity(0.35),
        filledSymbol: String = "star.fill",
        emptySymbol: String = "star",
        isInteractive: Bool = true
    ) {
        self._rating = rating
        self.maxRating = max(1, maxRating)
        self.starSize = starSize
        self.spacing = spacing
        self.filledColor = filledColor
        self.emptyColor = emptyColor
        self.filledSymbol = filledSymbol
        self.emptySymbol = emptySymbol
        self.isInteractive = isInteractive
    }

    public var body: some View {
        let totalWidth = Self.totalWidth(maxRating: maxRating, starSize: starSize, spacing: spacing)

        GeometryReader { proxy in
            HStack(spacing: spacing) {
                ForEach(1...maxRating, id: \.self) { index in
                    star(isOn: index <= clampedRating)
                        .frame(width: starSize, height: starSize)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard isInteractive else { return }
                            setRating(index)
                        }
                }
            }
            .frame(width: totalWidth, height: starSize, alignment: .leading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard isInteractive else { return }
                        updateRating(by: value.location.x, totalWidth: proxy.size.width)
                    }
                    .onEnded { value in
                        guard isInteractive else { return }
                        updateRating(by: value.location.x, totalWidth: proxy.size.width)
                    }
            )
        }
        .frame(width: totalWidth, height: starSize)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Star Rating")
        .accessibilityValue("\(clampedRating) / \(maxRating)")
    }

    private var clampedRating: Int {
        min(max(rating, 0), maxRating)
    }

    private func star(isOn: Bool) -> some View {
        ZStack {
            Image(systemName: emptySymbol)
                .resizable()
                .scaledToFit()
                .foregroundColor(emptyColor)

            if isOn {
                Image(systemName: filledSymbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(filledColor)
            }
        }
    }

    private func setRating(_ newValue: Int) {
        rating = min(max(newValue, 0), maxRating)
    }

    private func updateRating(by x: CGFloat, totalWidth: CGFloat) {
        let unit = starSize + spacing
        let width = max(totalWidth, Self.totalWidth(maxRating: maxRating, starSize: starSize, spacing: spacing))
        let clampedX = min(max(x, 0), width)

        if clampedX <= 0 {
            setRating(0)
            return
        }

        let rawIndex = Int(clampedX / unit)
        let inUnitX = clampedX - (CGFloat(rawIndex) * unit)

        var value = rawIndex + 1
        if inUnitX > starSize {
            let gapX = inUnitX - starSize
            if gapX > spacing / 2 {
                value = rawIndex + 2
            }
        }

        setRating(value)
    }

    private static func totalWidth(maxRating: Int, starSize: CGFloat, spacing: CGFloat) -> CGFloat {
        let count = max(1, maxRating)
        return (CGFloat(count) * starSize) + (CGFloat(count - 1) * spacing)
    }
}
// endregion

#if DEBUG
struct YQSUIStarRating_Previews: PreviewProvider {
    struct Demo: View {
        @State var v1: Int = 3
        @State var v2: Int = 0
        @State var v3: Int = 5
        var body: some View {
            VStack(spacing: 20) {
                YQSUIStarRating(rating: $v1)
                YQSUIStarRating(rating: $v2, maxRating: 7, starSize: 28, spacing: 10, filledColor: .orange)
                YQSUIStarRating(rating: $v3, starSize: 32, spacing: 12, filledColor: .yellow, emptyColor: .gray.opacity(0.2), isInteractive: false)
                Text("当前评分：\(v1)")
            }
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
    static var previews: some View {
        Demo().previewDisplayName("YQSUIStarRating")
    }
}
#endif

