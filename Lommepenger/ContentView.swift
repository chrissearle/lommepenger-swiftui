import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var showingScanner = false
    @State private var config : Config? = nil
    @State private var authenticated = false
    
    var body: some View {
        VStack {
            Button(action: {
                self.showingScanner = true
            }) {
                Image(systemName: "qrcode")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView(scannedData: Binding(
                get: { "" },
                set: self.newScanData
                ))
            }

            if (self.config != nil) {
                if (self.authenticated == false) {
                    Text("Please authenticate")
                } else {
                    Text(config!.accountNr)
                }
            } else {
                Text("You need to scan in a configuation")
            }
        }
        .onAppear {
            self.config = Config.loadConfig()
            
            if (self.config != nil && self.authenticated == false) {
                self.askForAuth()
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
                print("\(accessToken ?? "No token")")
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
