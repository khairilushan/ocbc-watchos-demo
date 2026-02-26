import AppCore
import SwiftUI

public struct HomeScreen: View {
    @Environment(\.router) private var router

    public init() {}

    public var body: some View {
        HomeMenuListView { destination in
            router?.route(to: destination)
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
            .environment(\.router, Router())
    }
}
