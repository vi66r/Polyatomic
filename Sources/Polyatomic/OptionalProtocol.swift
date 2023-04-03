import Foundation

public protocol OptionalProtocol {
    func wrappedType() -> Any.Type
}

extension Optional : OptionalProtocol {
    public func wrappedType() -> Any.Type {
        return Wrapped.self
    }
}
