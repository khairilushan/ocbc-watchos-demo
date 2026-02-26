import SwiftUI

public struct OCBCLoadingView: View {
    public init() {}

    public var body: some View {
        LoadingPulseBars()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}

private struct LoadingPulseBars: View {
    private let barCount = 5
    private let barSpacing: CGFloat = 6

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            HStack(alignment: .center, spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    let value = animatedValue(at: index, time: time)
                    Capsule()
                        .fill(.red.opacity(0.5 + (0.45 * value)))
                        .frame(width: 10, height: 8 + (30 * value))
                }
            }
            .frame(height: 42)
        }
        .accessibilityLabel("Loading")
    }

    private func animatedValue(at index: Int, time: TimeInterval) -> CGFloat {
        let shifted = (time * 4.2) - (Double(index) * 0.28)
        let wave = (sin(shifted) + 1) / 2
        return CGFloat(wave)
    }
}

#Preview {
    OCBCLoadingView()
        .frame(width: 198, height: 242)
}
