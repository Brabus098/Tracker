//  DateFormatted.swift

import Foundation

extension String {
    func dataFormatter() -> String{
        let result = self.split(separator: ",")
        return String(result[0])
    }
}

extension Date {
    func toShortFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: self)
    }
}
