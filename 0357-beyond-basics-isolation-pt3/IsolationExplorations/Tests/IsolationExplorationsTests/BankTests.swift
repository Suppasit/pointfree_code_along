import Testing
@testable import IsolationExplorations

@Suite struct BankTests {
    @Test func basic() async throws {
        let bank: Bank = Bank()
        let id1: Bank.Account.ID = await bank.openAccount(initialDeposit: 100)
        let id2: Bank.Account.ID = await bank.openAccount(initialDeposit: 100)
        try await bank.transfer(amount: 50, from: id1, to: id2)
        #expect(bank.totalDeposit == 200)
        #expect(try bank.account(for: id1).balance == 50)
        #expect(try bank.account(for: id2).balance == 150)
    }
    
    @Test func newAccountRush() async {
        let bank: Bank = Bank()
        await withTaskGroup { group in
            group.addTask {
                await bank.openAccount(initialDeposit: 100)
            }
        }
        #expect(bank.totalDeposit == 100 * 1000)
    }
}
