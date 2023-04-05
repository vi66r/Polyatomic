import Foundation

extension String: SchemaConvertible {
    public static func schemaConversionInstance() -> String { "" }
}

extension Array: SchemaConvertible {
    public static func schemaConversionInstance() -> Array<Element> {[]}
}
