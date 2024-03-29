import Foundation

public protocol SchemaConvertible {
    static func schemaConversionInstance() -> Self
}

public enum SchemaConvertibleError: Error {
    case nonConformingType(String)
    case notEncodable
}

public extension SchemaConvertible {
    
    private static func propertyDescriptor(for value: Any) throws -> [String: Any] {
        var _propertyDescriptor: [String: Any] = [:]
        let valueType = type(of: value)

        if valueType is Date.Type || valueType is Optional<Date>.Type {
            _propertyDescriptor["type"] = "string"
            _propertyDescriptor["format"] = "date-time"
        } else if valueType is UUID.Type || valueType is Optional<UUID>.Type {
            _propertyDescriptor["type"] = "string"
            _propertyDescriptor["format"] = "uuid"
        } else if valueType is String.Type || valueType is Optional<String>.Type {
            _propertyDescriptor["type"] = "string"
        } else if valueType is Int.Type || valueType is Optional<Int>.Type {
            _propertyDescriptor["type"] = "integer"
        } else if valueType is Double.Type || valueType is Optional<Double>.Type {
            _propertyDescriptor["type"] = "number"
        } else if valueType is Bool.Type || valueType is Optional<Bool>.Type {
            _propertyDescriptor["type"] = "boolean"
        } else if (valueType is Codable.Type || valueType is Optional<Codable>.Type), let raw = value as? any RawRepresentable {
            _propertyDescriptor = try propertyDescriptor(for: raw.rawValue)
        } else if let array = value as? Array<Any>, let element = array.first {
            _propertyDescriptor = try propertyDescriptor(for: element)
        } else if let valueType = valueType as? SchemaConvertible.Type {
            _propertyDescriptor = try valueType._schema()
        } else if let value = value as? Optional<SchemaConvertible> {
            let unwrapped = value.unsafelyUnwrapped
            _propertyDescriptor = try type(of: unwrapped)._schema()
        } else {
            print("Polyatomic Schema Conversion Error: Non-conforming type encountered in propertyDescriptor for value: \(value)")
            throw SchemaConvertibleError.nonConformingType("Polyatomic Schema Conversion Error: Non-conforming type encountered in propertyDescriptor for value: \(value)")
        }

        return _propertyDescriptor
    }
    
    private static func _schema() throws -> [String: Any] {
        let instance = Self.schemaConversionInstance()
        let mirror = Mirror(reflecting: instance)
        var properties: [String: Any] = [:]
        var defs: [String: Any] = [:]
        var required: [String] = []

        for child in mirror.children {
            guard let label = child.label else { fatalError("Polyatomic Schema Conversion Error: Found child without label during _schema generation") }
            
            if let array = child.value as? Array<SchemaConvertible>, let element = array.first {
                properties[label] = ["type" : "array", "items" : ["$ref" : "#/$defs/\(type(of: element))"]]
                defs["\(type(of: element))"] = try type(of: element)._schema()
                continue
            }
            
            if let enumeration = child.value as? any (CaseIterable & RawRepresentable),
               let values = type(of: enumeration).allCases as any Collection as? [any RawRepresentable] {
                let mapped = values.compactMap({ $0.rawValue })
                properties[label] = ["enum": mapped]
                
                if !(child.value is OptionalProtocol) {
                    required.append(label)
                }
                
                continue
            }
            
            if !(child.value is OptionalProtocol) {
                required.append(label)
            }
            
            properties[label] = try propertyDescriptor(for: child.value)
        }

        var schema: [String: Any] = [
            "$schema": "https://json-schema.org/draft/2020-12/schema",
            "description" : "a representation of \(type(of: instance))",
            "type": "object",
            "properties": properties
        ]
        
        if !required.isEmpty {
            schema["required"] = required
        }
        
        if !defs.isEmpty {
            schema["$defs"] = defs
        }

        return schema
    }
    
    static func schema() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let schema = try Self._schema()
            let schemaData = try JSONSerialization.data(withJSONObject: schema, options: .prettyPrinted)
            if let schemaString = String(data: schemaData, encoding: .utf8) {
                return schemaString
            }
        } catch let error as SchemaConvertibleError {
            print("Error encountered during schema generation: \(error)")
            throw error
        }

        return ""
    }
    
    func stringRepresentation() throws -> String {
        guard let value = self as? Codable else {
            print("Polyatomic Schema Conversion Error: Attempted to generate string representation for a non-Codable type")
            throw SchemaConvertibleError.notEncodable
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(value)
            if let stringRepresentation = String(data: data, encoding: .utf8) {
                return stringRepresentation
            }
        } catch let error as SchemaConvertibleError {
            print("Error encountered during stringRepresentation generation: \(error)")
            throw error
        }

        return ""
    }
}
