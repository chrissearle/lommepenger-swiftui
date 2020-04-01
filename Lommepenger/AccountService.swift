import Foundation
import Alamofire

struct Account : Decodable {
    let accountId: String
    let accountNumber: String
    let ownerCustomerId: String
    let name: String
    let accountType: String
    let available: Double
    let balance: Double
    let creditLimit: Double
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case accountNumber
        case ownerCustomerId
        case name
        case accountType
        case available
        case balance
        case creditLimit
    }

}

struct Accounts : Decodable {
    let accounts: [Account]
    
    enum CodingKeys: String, CodingKey {
        case accounts = "items"
    }
}

class AccountService : ObservableObject {
    @Published public var account : Account? = nil
    
    public func refresh(token: String, config: Config) {
        let decoder = JSONDecoder()

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json",
            "customerId": config.userId
        ]

        let request = AF.request("https://api.sbanken.no/exec.bank/api/v1/accounts/",
                                 method: .get,
                                 headers: headers)
        
        request.responseDecodable(of: Accounts.self, decoder: decoder) { (response) in
            if let error = response.error {
                print("Unable to fetch accounts \(response) \(error.localizedDescription)")
                
                return
            }
            
            guard let account = response.value?.accounts.filter({ (account) -> Bool in
                account.accountNumber == config.accountNr
            }).first else {
                print("Unable to find account")

                return
            }

            self.account = account
        }
    }
}
