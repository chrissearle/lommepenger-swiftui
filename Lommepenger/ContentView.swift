import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var showingScanner = false
    @State private var config : Config? = nil
    
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
                Text(config!.accountNr)
            } else {
                Text("You need to scan in a configuation")
            }
        }
        .onAppear {
            self.config = Config.loadConfig()
        }
    }
    
    func newScanData(_ code: String) {
        if let config = Config.decodeConfig(json: code) {
            config.save()
            self.config = config
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
