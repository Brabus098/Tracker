//  IntSuffics.swift

extension Int {
    func findThe() -> String{
        
        let lastTwoDigits = abs(self) % 100
        let lastDigit = abs(self) % 10
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "дней"
        }
        
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
}
