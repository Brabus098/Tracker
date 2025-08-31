//  DateFormatted.swift

extension String {
    func dataFormatter() -> String{
        let result = self.split(separator: ",")
        return String(result[0])
    }
}
