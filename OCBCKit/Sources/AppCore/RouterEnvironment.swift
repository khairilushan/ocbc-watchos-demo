import SwiftUI

private struct RouterKey: EnvironmentKey {
    static let defaultValue: Router? = nil
}

public extension EnvironmentValues {
    var router: Router? {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}
