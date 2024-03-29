import SwiftUI
import CodeScanner

let simulatedData = """
{
    "clientId": "clientId",
    "clientSecret": "clientSecret",
    "accountNr": "12345678903"
}
"""

struct ScannerView: View {
    @Environment(\.presentationMode) var presentation

    @Binding var scannedData : String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Scan").font(.title).padding(.leading, 16.0)
                Spacer()
                Image(systemName: "xmark.square")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        self.presentation.wrappedValue.dismiss()
                    }
            }.padding()
            
            CodeScannerView(codeTypes: [.qr], simulatedData: simulatedData) { result in
                switch result {
                case .success(let code):
                    self.scannedData = code.string
                case .failure(let error):
                    print(error)
                }
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(scannedData: .constant(""))
    }
}
