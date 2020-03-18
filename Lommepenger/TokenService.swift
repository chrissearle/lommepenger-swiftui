import Foundation
import Alamofire

struct Token : Decodable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

extension String {
    public func encodeForAuth() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-_.!~*'()")
        
        return self.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }
}

class TokenService {
    public static func getToken(config: Config, onComplete: @escaping (_ accessToken: String?) -> Void) {
        let decoder = JSONDecoder()
        
        guard let username = config.clientId.encodeForAuth() else {
            onComplete(nil)
            
            return
        }
        
        guard let password = config.clientSecret.encodeForAuth() else {
            onComplete(nil)
            
            return
        }
        
        let basicAuth = Data("\(username):\(password)".utf8).base64EncodedString()
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuth)",
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters = ["grant_type": "client_credentials"]
        
        let request = AF.request("https://auth.sbanken.no/identityserver/connect/token",
                                 method: .post,
                                 parameters: parameters,
                                 encoding: URLEncoding.httpBody,
                                 headers: headers)
        
        request.responseDecodable(of: Token.self, decoder: decoder) { (response) in
            if let error = response.error {
                print("Unable to fetch token \(response) \(error.localizedDescription)")
                
                onComplete(nil)
                
                return
            }
            
            guard let token = response.value else {
                print("Unable to read token")
                
                onComplete(nil)
                
                return
            }
            
            onComplete(token.accessToken)
        }
    }
}
