import SwiftUI

extension Date {
    func displayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"

        return formatter.string(from: self)
    }
}

struct TransactionView: View {
    public var transaction: Transaction
    
    var color : Color {
        if transaction.amount > 0 {
            return Color.yellow
        } else {
            return Color.red
        }
    }
    
    var description : String {
        if (transaction.reserved) {
            return "Reservert: \(transaction.text)"
        } else {
            return transaction.text
        }
    }
    
    var iconName : String {
        if (transaction.transType == "KREDITRTE") {
            return "arrowtriangle.up.fill"
        } else if (transaction.transType == "OVFNETTB") {
            if (transaction.amount > 0) {
                return "arrowshape.turn.up.right.fill"
            } else {
                return "arrowshape.turn.up.left.fill"
            }
        }

        return "bag.fill"
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                HStack {
                    Text(transaction.date.displayDate())
                    Spacer()
                    Text(transaction.amount.currency())
                }
                Text(description)
                    .font(.caption)
            }
        }.foregroundColor(self.color)
    }
}

struct TransactionsView: View {
    public var account : Account
    public var config: Config
    public var token: String
    
    @ObservedObject var transactionService = TransactionService()

    var body: some View {
        VStack {
            Text("Aktivitet")
                .padding(.vertical)
                .font(.headline)
            .onAppear() {
                self.refresh()
            }
            List {
                ForEach(transactionService.transactionList, id: \.self) { transaction in
                    TransactionView(transaction: transaction)
                }
            }
        }
    }
    
    func refresh() {
        transactionService.refresh(token: token, config: config, accountId: account.accountId)
    }
}

