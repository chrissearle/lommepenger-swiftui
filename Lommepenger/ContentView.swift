import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var showingScanner = false
    @State private var config : Config? = nil
    @State private var authenticated = false
    @State private var token = ""

    @ObservedObject var accountService = AccountService()
    
    var body: some View {
        NavigationView {
            VStack {
                if (self.config != nil) {
                    if (self.authenticated == false) {
                        Text("Please authenticate")
                    } else {
                        if (accountService.account != nil) {
                            VStack {
                                AccountView(account: accountService.account!)
                                    .navigationBarTitle(Text(accountService.account!.name), displayMode: .inline)
                                TransactionsView(account: accountService.account!, config: self.config!, token: self.token)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
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
    
    func refresh() {
        if let config = self.config {
            TokenService.getToken(config: config) { (accessToken) in
                if let token = accessToken {
                    self.accountService.refresh(token: token, config: config)
                    self.token = token
                }
            }
        }
    }
    
    func askForAuth() {
        authenticateUser() { status in
            switch(status) {
            case .OK:
                self.authenticated = true
                self.refresh()
            case .Error:
                self.authenticated = false
            case .Unavailable:
                self.authenticated = true
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
