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
        decoder.dateDecodingStrategy = .iso8601

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json",
            "customerId": config.userId
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

        let request = AF.request("https://api.sbanken.no/exec.bank/api/v1/transactions/\(accountId)",
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

/*
 let formatter = DateFormatter()
 formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
 if let result = formatter.date(from: time) {print result}

 let date = Calendar.current.date(byAdding: .month, value: 1, to: Date())
 
 
 
 let decoder = JSONDecoder()
 decoder.dateDecodingStrategy = .iso8601
 
 or
 
 
 public var decoder: JSONDecoder = {
     let jsonDecoder = JSONDecoder()
     
     jsonDecoder.dateDecodingStrategy = .custom({ decoder -> Date in
         let container = try decoder.singleValueContainer()
         let dateString = try container.decode(String.self)
         let length = dateString.count
         
         var date: Date?
         if length == 19 {
             let formatter = DateFormatter()
             formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
             formatter.calendar = Calendar(identifier: .iso8601)
             formatter.timeZone = TimeZone(secondsFromGMT: 0)
             formatter.locale = Locale(identifier: "en_US_POSIX")
             date = formatter.date(from: dateString)
         } else {
             date = ISO8601DateFormatter().date(from: dateString)
         }
         
         guard date != nil else {
             throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
         }
         
         return date!
     })
     
     // 19
     // 2021-04-01T00:00:00
     //jsonDecoder.dateDecodingStrategy = .iso8601
     return jsonDecoder
 }()
 */
