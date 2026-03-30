import Testing
@testable import IsolationExplorations

@Suite struct BankTests {
    @Test func basic() async throws {
        let bank: Bank = Bank()
        let id1: Bank.Account.ID = bank.openAccount(initialDeposit: 100)
        let id2: Bank.Account.ID = bank.openAccount(initialDeposit: 100)
        try bank.transfer(amount: 50, from: id1, to: id2)
        #expect(bank.totalDeposit == 200)
        #expect(try bank.account(for: id1) { $0.balance } == 50)
        #expect(try bank.account(for: id2) { $0.balance } == 150)
    }
    
    @Test func newAccountRush() async {
        let bank: Bank = Bank()
        await withTaskGroup { group in
            for _ in 1...100 {
                group.addTask {
                    bank.openAccount(initialDeposit: 100)
                }
            }
        }
        #expect(bank.totalDeposit == 100 * 100)
    }
    
    @Test func busyDepositDay() async throws {
        let bank = Bank()
        let id = bank.openAccount(initialDeposit: 0)
        await withThrowingTaskGroup { group in
            for _ in 1...1000 {
                group.addTask {
                    try bank.account(for: id) { account in
                        account.deposti(100)
                    }
                }
            }
        }
        
        #expect(bank.totalDeposit == 100 * 1000)
    }
}
