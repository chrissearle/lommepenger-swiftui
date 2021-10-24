import Foundation
import Alamofire

struct Transaction : Decodable, Hashable {
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
        case reserved = "isReservation"
    }
}

struct Transactions : Decodable {
    let transactions: [Transaction]
    
    enum CodingKeys: String, CodingKey {
        case transactions = "items"
    }
}

class TransactionService : ObservableObject {
    @Published public var transactionList : [Transaction] = []
    
    public func refresh(token: String, config: Config, accountId: String) {
        let decoder = JSONDecoder()
        
        let dateDecodeFormatter = DateFormatter()
        dateDecodeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateDecodeFormatter)

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        var parameters: [String: String] = [
            "index": "0",
            "length": "20"
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) {
            parameters["startDate"] = formatter.string(from: startDate)
        }

        let request = AF.request("https://publicapi.sbanken.no/apibeta/api/v1/transactions/\(accountId)",
                                 method: .get,
                                 parameters: parameters,
                                 headers: headers)

        request.responseDecodable(of: Transactions.self, decoder: decoder) { (response) in
            if let error = response.error {
                print("Unable to fetch transactions \(response) \(error.localizedDescription)")
                
                return
            }
            
            guard let transactions = response.value?.transactions else {
                print("Unable to parse transactions")

                return
            }
            
            self.transactionList = transactions
        }
    }
}
