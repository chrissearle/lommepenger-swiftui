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
    @Published public var cardAccount : Account? = nil
    @Published public var mainAccount: Account? = nil
    
    public func refresh(token: String, config: Config) {
        let decoder = JSONDecoder()

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]

        let request = AF.request("https://publicapi.sbanken.no/apibeta/api/v1/accounts/",
                                 method: .get,
                                 headers: headers)
        
        request.responseDecodable(of: Accounts.self, decoder: decoder) { (response) in
            if let error = response.error {
                print("Unable to fetch accounts \(response) \(error.localizedDescription)")
                
                return
            }
            
            guard let cardAccount = self.findAccount(accounts: response.value, accountNr: config.cardAccountNr)
            else {
                print("Unable to find card account")

                return
            }
            
            self.cardAccount = cardAccount
            
            guard let mainAccount = self.findAccount(accounts: response.value, accountNr: config.mainAccountNr)
            else {
                print("Unable to find main account")

                return
            }

            self.mainAccount = mainAccount
        }
    }
    
    private func findAccount(accounts: Accounts?, accountNr: String) -> Account? {
        guard let account = accounts?.accounts.filter({ (account) -> Bool in
            account.accountNumber == accountNr
        }).first else {
            print("Unable to find account")

            return nil
        }
        
        return account
    }
}
