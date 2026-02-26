public enum ScreenState<Value> {
    case loading
    case success(Value)
    case failure(String)
}
