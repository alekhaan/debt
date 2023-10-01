//
//  DebtorStore.swift
//  Debtors
//
//  Created by AlexGod on 04.07.2023.
//

import Foundation
import UserNotifications

class DebtorStore: ObservableObject {
    @Published var debtors: [Debtor] = []
    
    private let key = "DebtorsKey"
    
    init() {
        loadDebtors()
    }
    
    func addDebt(_ debt: Debt, to debtor: Debtor) {
        if let index = debtors.firstIndex(where: { $0.id == debtor.id}) {
            debtors[index].debts.append(debt)
        }
        saveDebtors()
    }
    
    func addDebtor(_ debtor: Debtor) {
        if var existingDebtor = debtors.first(where: { $0.name == debtor.name}) {
            existingDebtor.debts.append(contentsOf: debtor.debts)
        } else {
            debtors.append(debtor)
        }
        saveDebtors()
    }
    
    func removeDebt(_ debt: Debt, from debtor: Debtor) {
        if let debtorIndex = debtors.firstIndex(where: { $0.id == debtor.id }),
           let debtIndex = debtors[debtorIndex].debts.firstIndex(where: { $0.id == debt.id }) {
            debtors[debtorIndex].debts.remove(at: debtIndex)
            saveDebtors()
        }
    }
    
    func removeDebtor(_ debtor: Debtor) {
        if let index = debtors.firstIndex(where: {
            $0.id == debtor.id
        }) {
            debtors.remove(at: index)
            saveDebtors()
        }
    }
    
    func deactivateDebt(_ debt: Debt, from debtor: Debtor) {
        if let debtorIndex = debtors.firstIndex(where: { $0.id == debtor.id }) {
            if let debtIndex = debtors[debtorIndex].debts.firstIndex(where: { $0.id == debt.id}) {
                debtors[debtorIndex].debts[debtIndex].isActive = false
                debtors[debtorIndex].debts[debtIndex].closeDate = Date()
                debtors[debtorIndex].debts[debtIndex].paidAmount = debtors[debtorIndex].debts[debtIndex].totalAmount
                saveDebtors()
            }
        }
    }
    
    private func saveDebtors() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(debtors)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save debtors: \(error)")
        }
    }
    
    private func loadDebtors() {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let loadedDebtors = try decoder.decode([Debtor].self, from: data)
                debtors = loadedDebtors
            } catch {
                print("Failed to load debtors: \(error)")
            }
        }
    }
}
