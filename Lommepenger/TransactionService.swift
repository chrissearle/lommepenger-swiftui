import Foundation
import Alamofire

struct Transaction : Decodable {
    let date: Date
    let amount: Double
    let text: String
    let transType: String
    let reserved: Bool

    enum CodingKeys: String, CodingKey {
        case date = "accountingDate"
        case amount
        case text
        case transType = "transactionType"
        case reserved = "isReservationb"
    }
}

struct Transactions : Decodable {
    let transactions: [Transaction]
    
    enum CodingKeys: String, CodingKey {
        case transactions = "items"
    }
}
