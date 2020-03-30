import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var showingScanner = false
    @State private var config : Config? = nil
    @State private var authenticated = false
    
    @State private var account = Account(accountId: "",
                                         accountNumber: "",
                                         ownerCustomerId: "",
                                         name: "Lommepenger",
                                         accountType: "",
                                         available: 0.0,
                                         balance: 0.0,
                                         creditLimit: 0.0)
    
    var body: some View {
        NavigationView {
            VStack {
                if (self.config != nil) {
                    if (self.authenticated == false) {
                        Text("Please authenticate")
                    } else {
                        AccountView(account: account)
                            .navigationBarTitle(Text(account.name), displayMode: .inline)
                    }
                } else {
                    Text("You need to scan in a configuation")
                }
            }
            .navigationBarItems(trailing: Button(action: {
                self.showingScanner = true
            }) {
                Image(systemName: "qrcode")
                    .resizable()
                    .frame(width: 32, height: 32)
                }
            )
                .sheet(isPresented: $showingScanner) {
                    ScannerView(scannedData: Binding(
                        get: { "" },
                        set: self.newScanData
                    ))
            }
            .onAppear {
                self.config = Config.loadConfig()
                
                if (self.config != nil && self.authenticated == false) {
                    self.askForAuth()
                }
            }
        }
    }
    
    func askForAuth() {
        authenticateUser() { status in
            switch(status) {
            case .OK:
                self.authenticated = true
                self.getToken()
            case .Error:
                self.authenticated = false
            case .Unavailable:
                self.authenticated = true
            }
        }
    }
    
    func getToken() {
        if let config = self.config {
            TokenService.getToken(config: config) { (accessToken) in
                if let token = accessToken {
                    AccountService.getAccountDetails(config: config, token: token) { (account) in
                        if let account = account {
                            self.account = account
                        } else {
                            print("No account")
                        }
                    }
                } else {
                    print("No token")
                }
            }
        }
    }
    
    func newScanData(_ code: String) {
        if let config = Config.decodeConfig(json: code) {
            config.save()
            self.config = config
            
            if (self.authenticated == false) {
                self.askForAuth()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
