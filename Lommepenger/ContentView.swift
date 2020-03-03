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
            VStack {
                HStack {
                    Spacer()
                    Text("Scan").font(.title).padding(.leading, 16.0)
                    Spacer()
                    Image(systemName: "xmark.square")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            self.showingScanner = false
                        }
                }.padding()
                CodeScannerView(codeTypes: [.qr], simulatedData: "-") { result in
                    switch result {
                    case .success(let code):
                        print(code)

                        if let data = code.data(using: .utf8) {
                            let decoder = JSONDecoder()

                            if let config = try? decoder.decode(Config.self, from: data) {
                                print(config.clientId)
                                print(config.clientSecret)
                                print(config.userId)
                                print(config.accountNr)
                            }
                        }

                    case .failure(let error):
                        print(error)
                    }
                    self.showingScanner = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
