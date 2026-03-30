//
//  Bank.swift
//  IsolationExplorations
//
//  Created by Suppasit chuwatsawat on 27/3/2569 BE.
//

import Foundation

final class Bank: @unchecked Sendable {
    private let lock = NSLock()
    private var accounts: [Account.ID: Account] = [:]
    
    func openAccount(initialDeposit: Int = 0) -> Account.ID {
        lock.withLock {
            let id = UUID()
            accounts[id] = Account(id: id, balance: initialDeposit)
            return id
        }
    }
    
    func transfer(
        amount: Int,
        from fromID: Account.ID,
        to toID: Account.ID
    ) throws {
        try lock.withLock {
            let fromAccount = try account(for: fromID)
            let toAccount = try account(for: toID)
            try fromAccount.withdraw(amount)
            toAccount.deposti(amount)
        }
    }
    
    var totalDeposit: Int {
        lock.withLock {
            accounts.values.reduce(into: 0) { $0 += $1.balance }
        }
    }
    
    func account(for id: Account.ID) throws -> Account {
        try lock.withLock {
            guard let account: Bank.Account = accounts[id]
            else {
                struct AccountNOtFound: Error {}
                throw AccountNOtFound()
            }
            return account
        }
    }
    
    class Account: Identifiable {
        let id: UUID
        var balance: Int
        init(id: UUID, balance: Int = 0) {
            self.id = id
            self.balance = balance
        }
        func deposti(_ amount: Int) {
            balance += amount
        }
        func withdraw(_ amount: Int) throws {
            guard balance >= amount
            else {
                struct InsufficientFunds: Error {}
                throw InsufficientFunds()
            }
            balance -= amount
        }
    }
}
