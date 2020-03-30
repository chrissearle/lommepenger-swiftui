import SwiftUI


extension String {
    func sub(_ start: Int, _ count: Int) -> String{
        return String(self[self.index(self.startIndex, offsetBy: start)..<self.index(self.startIndex, offsetBy: start + count)])
    }
    
    func accountFormat() -> String {
        if (self.count == 11)   {
            return String("\(self.sub(0, 4)) \(self.sub(4, 2)) \(self.sub(6, 5))")
        } else {
            return self
        }
    }
}

extension Double {
    func inNok() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        guard let formatted = formatter.string(from: self as NSNumber) else {
            return "\(self)"
        }
        
        return formatted
    }
}

struct AccountView: View {
    public var account : Account
    
    var body: some View {
        VStack {
            Text(account.accountNumber.accountFormat())
                .padding(.bottom)
                .padding(.top)
                .font(.caption)
            HStack {
                VStack {
                    Text("Disponibelt")
                        .font(.caption)
                    Text(account.available.inNok())
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("Saldo")
                        .font(.caption)
                    Text(account.balance.inNok())
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var testAccount = Account(accountId: "1234",
                                     accountNumber: "12345678903",
                                     ownerCustomerId: "12345678903",
                                     name: "Test Account",
                                     accountType: "Standard",
                                     available: 10.0,
                                     balance: 10.0,
                                     creditLimit: 0.0)

    static var previews: some View {
        AccountView(account: testAccount)
    }
}
