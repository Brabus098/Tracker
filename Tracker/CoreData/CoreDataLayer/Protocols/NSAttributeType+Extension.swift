//  NSAttributeType+Extension.swift

import CoreData

extension NSAttributeType {
    func toString() -> String {
        switch self {
        case .integer16AttributeType: return "Int16"
        case .integer32AttributeType: return "Int32"
        case .integer64AttributeType: return "Int64"
        case .decimalAttributeType: return "Decimal"
        case .doubleAttributeType: return "Double"
        case .floatAttributeType: return "Float"
        case .stringAttributeType: return "String"
        case .booleanAttributeType: return "Bool"
        case .dateAttributeType: return "Date"
        case .binaryDataAttributeType: return "Binary"
        case .UUIDAttributeType: return "UUID"
        case .URIAttributeType: return "URI"
        default: return "Unknown"
        }
    }
}
