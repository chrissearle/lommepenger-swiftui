import Foundation
import LocalAuthentication

enum AuthStatus {
    case OK
    case Error
    case Unavailable
}

func authenticateUser(_ callback: @escaping (_ status: AuthStatus) -> Void) {
    let context = LAContext()
    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock") { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    print("Authentication OK")
                    callback(.OK)
                } else {
                    print("Authentication Error")
                    callback(.Error)
                }
            }
        }
    } else {
        print("Authentication Unavailable")
        callback(.Unavailable)
    }
}
