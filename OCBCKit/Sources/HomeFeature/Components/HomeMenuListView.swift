import AppCore
import SwiftUI

struct HomeMenuListView: View {
    let items: [HomeMenuItem]
    let onSelect: (Destination) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(items) { item in
                    Button {
                        onSelect(item.destination)
                    } label: {
                        HomeMenuRowContent(item: item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item.accessibilityLabel)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}
