//  TrackerRecord.swift

import Foundation

// Сущность для хранения записи о том, что некий трекер был выполнен на некоторую дату
struct TrackerRecord {
    let id: UInt
    let trackCompletionDate: [String]
}
