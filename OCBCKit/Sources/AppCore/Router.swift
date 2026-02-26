import Observation

@Observable
public final class Router: @unchecked Sendable {
    public var path: [Destination]

    public init(path: [Destination] = []) {
        self.path = path
    }

    public func route(to destination: Destination) {
        path.append(destination)
    }

    public func popToRoot() {
        path.removeAll()
    }
}
