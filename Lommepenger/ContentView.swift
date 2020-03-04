import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var showingScanner = false
    
    var body: some View {
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
    }
    
    func newScanData(_ code: String) {
        if let data = code.data(using: .utf8) {
            let decoder = JSONDecoder()

            if let config = try? decoder.decode(Config.self, from: data) {
                print(config.clientId)
                print(config.clientSecret)
                print(config.userId)
                print(config.accountNr)
            } else {
                print("Could not decode \(code)")
            }
        } else {
            print("Could not convert to data \(code)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
