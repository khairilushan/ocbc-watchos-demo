import SwiftUI

struct PinKeyboardGridView: View {
    let keys: [PinKeyboardKey]
    let digitTapped: (String) -> Void
    let deleteTapped: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(keys) { key in
                switch key {
                case let .digit(value):
                    PinKeyboardButton(label: value) {
                        digitTapped(value)
                    }
                case .delete:
                    PinDeleteButton(action: deleteTapped)
                case .empty:
                    Color.clear
                        .frame(height: 38)
                }
            }
        }
    }
}
