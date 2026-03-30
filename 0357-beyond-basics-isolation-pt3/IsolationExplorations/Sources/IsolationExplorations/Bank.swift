//
//  Bank.swift
//  IsolationExplorations
//
//  Created by Suppasit chuwatsawat on 27/3/2569 BE.
//

import Foundation

class Bank {
    private var accounts: [Account.ID: Account] = [:]
    
    func openAccount(initialDeposit: Int = 0) -> Account.ID {
        let id = UUID()
        accounts[id] = Account(id: id, balance: initialDeposit)
        return id
    }
    
    func transfer(
        amount: Int,
        from fromID: Account.ID,
        to toID: Account.ID
    ) throws {
        guard
            let fromAccount = accounts[fromID],
            let toAccount = accounts[toID]
        else {
            struct AccountNotFound: Error {}
            throw AccountNotFound()
        }
        fromAccount.balance -= amount
        toAccount.balance += amount
    }
    
    var totalDeposit: Int {
        accounts.values.reduce(into: 0) { $0 += $1.balance }
    }
    
    func account(for id: Account.ID) throws -> Account {
        guard let account: Bank.Account = accounts[id]
        else {
            struct AccountNOtFound: Error {}
            throw AccountNOtFound()
        }
        return account
    }
    
    class Account: Identifiable {
        let id: UUID
        var balance: Int
        init(id: UUID, balance: Int = 0) {
            self.id = id
            self.balance = balance
        }
    }
}
