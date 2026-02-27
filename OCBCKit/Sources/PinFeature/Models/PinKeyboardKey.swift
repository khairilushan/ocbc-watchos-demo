enum PinKeyboardKey: Hashable, Identifiable {
    case digit(String)
    case empty
    case delete

    var id: String {
        switch self {
        case let .digit(value):
            return "digit-\(value)"
        case .empty:
            return "empty"
        case .delete:
            return "delete"
        }
    }
}
