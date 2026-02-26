import AppCore
import SwiftUI

struct HomeMenuListView: View {
    let onSelect: (Destination) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(HomeMenuItem.items) { item in
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
