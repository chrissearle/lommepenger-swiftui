import Foundation

class Config : Codable {
    let clientId: String
    let clientSecret: String
    let userId: String
    let accountNr: String
    
    enum CodingKeys: String, CodingKey {
        case clientId
        case clientSecret
        case userId
        case accountNr
    }
}
