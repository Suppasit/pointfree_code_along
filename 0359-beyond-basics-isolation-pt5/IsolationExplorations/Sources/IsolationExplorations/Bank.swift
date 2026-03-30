//
//  Bank.swift
//  IsolationExplorations
//
//  Created by Suppasit chuwatsawat on 27/3/2569 BE.
//

import Foundation
import os

final class Bank: Sendable {
    private let accounts = OSAllocatedUnfairLock<[Account.ID: Account]>.init(checkedState: [:])
    
    func openAccount(initialDeposit: Int = 0) -> Account.ID {
        accounts.withLock {
            let id = UUID()
            $0[id] = Account(id: id, balance: initialDeposit)
            return id
        }
    }
    
    func transfer(
        amount: Int,
        from fromID: Account.ID,
        to toID: Account.ID
    ) throws {
        try accounts.withLock {
            let fromAccount = try $0.account(for: fromID)
            let toAccount = try $0.account(for: toID)
            try fromAccount.withdraw(amount)
            toAccount.deposti(amount)
        }
    }
    
    var totalDeposit: Int {
        accounts.withLock {
            $0.values.reduce(into: 0) { $0 += $1.balance }
        }
    }
    
    func account<R: Sendable>(for id: Account.ID, body: @Sendable (Account) -> R) throws -> R {
        try accounts.withLock {
            try body($0.account(for: id))
        }
    }
    
    class Account: Identifiable {
        let id: UUID
        var balance: Int
        var balanceHistory: [Int] = []
        init(id: UUID, balance: Int = 0) {
            self.id = id
            self.balance = balance
        }
        func deposti(_ amount: Int) {
            balanceHistory.append(balance)
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

extension OSAllocatedUnfairLock {
    init(checkedState: @Sendable @autoclosure () -> State) {
        self.init(uncheckedState: checkedState())
    }
}

func foo() {
    class NS {}
    _ = OSAllocatedUnfairLock(checkedState: NS())
    /* 3 lines below is invalid */
//    let ns = NS()
//    _ = OSAllocatedUnfairLock(checkedState: ns)
//    _ = ns
}

extension [Bank.Account.ID: Bank.Account] {
    struct AccountNotFound: Error {}
    func account(for id: Key) throws -> Value {
        guard let value = self[id]
        else {
            throw AccountNotFound()
        }
        return value
    }
}
