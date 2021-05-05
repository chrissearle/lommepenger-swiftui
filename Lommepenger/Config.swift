import Foundation
import KeychainSwift

class Config : Codable {
    let clientId: String
    let clientSecret: String
    let accountNr: String
    
    enum CodingKeys: String, CodingKey {
        case clientId
        case clientSecret
        case accountNr
    }
}

extension Config {
    static func decodeConfig(json: String) -> Config? {
        if let data = json.data(using: .utf8) {
            let decoder = JSONDecoder()

            if let config = try? decoder.decode(Config.self, from: data) {
                return config
            } else {
                print("Could not decode \(json)")
            }
        } else {
            print("Could not convert to data \(json)")
        }
        
        return nil
    }
    
    func save() {
        let keychain = KeychainSwift()
        
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(self) {
            if let json = String(data: data, encoding: .utf8) {
                keychain.set(json, forKey: "AppConfig")
            }
        }
    }
    
    static func loadConfig() -> Config? {
        let keychain = KeychainSwift()
        
        if let json = keychain.get("AppConfig") {
            return decodeConfig(json: json)
        }
        
        return nil
    }
}
