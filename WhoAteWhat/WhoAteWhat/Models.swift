//
//  Models.swift
//  WhoAteWhat
//
//  Created by Kat Kampf on 7/21/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Receipt Models
struct Receipt: Codable, Identifiable {
    let id = UUID()
    var items: [ReceiptItem]
    var tax: Double
    var tip: Double
    var total: Double
    var currency: String
    var date: Date
    
    init(items: [ReceiptItem] = [], tax: Double = 0.0, tip: Double = 0.0, total: Double = 0.0, currency: String = "USD") {
        self.items = items
        self.tax = tax
        self.tip = tip
        self.total = total
        self.currency = currency
        self.date = Date()
    }
}

struct ReceiptItem: Codable, Identifiable {
    let id = UUID()
    var name: String
    var price: Double
    var quantity: Int
    
    init(name: String, price: Double, quantity: Int = 1) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}

// MARK: - Person Models
struct Person: Codable, Identifiable {
    let id = UUID()
    var name: String
    var items: [AssignedItem]
    
    init(name: String) {
        self.name = name
        self.items = []
    }
    
    var totalAmount: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    func taxAmount(receipt: Receipt?) -> Double {
        guard let receipt = receipt else { return 0 }
        let itemSubtotal = items.reduce(0) { $0 + $1.totalPrice }
        let receiptSubtotal = receipt.items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return receiptSubtotal > 0 ? (itemSubtotal / receiptSubtotal) * receipt.tax : 0
    }
    
    func tipAmount(receipt: Receipt?) -> Double {
        guard let receipt = receipt else { return 0 }
        let itemSubtotal = items.reduce(0) { $0 + $1.totalPrice }
        let receiptSubtotal = receipt.items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return receiptSubtotal > 0 ? (itemSubtotal / receiptSubtotal) * receipt.tip : 0
    }
    
    func finalTotal(receipt: Receipt?) -> Double {
        totalAmount + taxAmount(receipt: receipt) + tipAmount(receipt: receipt)
    }
    

}

struct AssignedItem: Codable, Identifiable {
    let id = UUID()
    var receiptItem: ReceiptItem
    var quantity: Int
    var sharePercentage: Double // For shared items (0.0 to 1.0)
    
    init(receiptItem: ReceiptItem, quantity: Int = 1, sharePercentage: Double = 1.0) {
        self.receiptItem = receiptItem
        self.quantity = quantity
        self.sharePercentage = sharePercentage
    }
    
    var totalPrice: Double {
        receiptItem.price * Double(quantity) * sharePercentage
    }
}

// MARK: - App State
class ReceiptSplitterViewModel: ObservableObject {
    @Published var receipt: Receipt?
    @Published var people: [Person] = []
    @Published var conversationHistory: [ConversationMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedImage: UIImage?
    
    // Computed properties
    var calculatedTotal: Double {
        people.reduce(0) { $0 + $1.finalTotal(receipt: receipt) }
    }
    
    var unassignedItems: [ReceiptItem] {
        guard let receipt = receipt else { return [] }
        
        let assignedItemIds = Set(people.flatMap { person in
            person.items.map { $0.receiptItem.id }
        })
        
        return receipt.items.filter { !assignedItemIds.contains($0.id) }
    }
    
    var isReceiptComplete: Bool {
        unassignedItems.isEmpty && !people.isEmpty
    }
    
    // MARK: - Methods
    func addPerson(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty && !people.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            people.append(Person(name: trimmedName))
        }
    }
    
    func findOrCreatePerson(name: String) -> Person {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existingPerson = people.first(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            return existingPerson
        } else {
            let newPerson = Person(name: trimmedName)
            people.append(newPerson)
            return newPerson
        }
    }
    
    func assignItemToPerson(item: ReceiptItem, personName: String, quantity: Int = 1, sharePercentage: Double = 1.0) {
        guard let personIndex = people.firstIndex(where: { $0.name.lowercased() == personName.lowercased() }) else {
            return
        }
        
        let assignedItem = AssignedItem(receiptItem: item, quantity: quantity, sharePercentage: sharePercentage)
        people[personIndex].items.append(assignedItem)
    }
    
    func removeItemFromPerson(itemId: UUID, personName: String) {
        guard let personIndex = people.firstIndex(where: { $0.name.lowercased() == personName.lowercased() }) else {
            return
        }
        
        people[personIndex].items.removeAll { $0.id == itemId }
    }
    
    func processNaturalLanguageInput(_ input: String) {
        let message = ConversationMessage(text: input, isUser: true)
        conversationHistory.append(message)
        
        // Improved parsing logic
        let inputLower = input.lowercased()
        let words = input.components(separatedBy: .whitespacesAndNewlines)
        
        // Extract person names (words that start with capital letters)
        let personNames = words.filter { word in
            word.count > 1 && word.first?.isUppercase == true
        }
        
        // Add detected people
        for name in personNames {
            addPerson(name: name)
        }
        
        // Improved item matching
        if let receipt = receipt {
            for item in receipt.items {
                let itemNameLower = item.name.lowercased()
                
                // Check for exact matches and partial matches
                if inputLower.contains(itemNameLower) || 
                   itemNameLower.components(separatedBy: " ").contains { word in
                    inputLower.contains(word)
                } {
                    // Find the person mentioned before this item
                    if let personName = findPersonBeforeItem(input: input, itemName: item.name) {
                        assignItemToPerson(item: item, personName: personName)
                    } else if let lastPerson = personNames.last {
                        // Fallback to last mentioned person
                        assignItemToPerson(item: item, personName: lastPerson)
                    }
                }
            }
        }
        
        // Add system response
        let response = generateSystemResponse(for: input)
        conversationHistory.append(ConversationMessage(text: response, isUser: false))
    }
    
    private func findPersonBeforeItem(input: String, itemName: String) -> String? {
        let words = input.components(separatedBy: .whitespacesAndNewlines)
        let itemNameLower = itemName.lowercased()
        
        for (index, word) in words.enumerated() {
            if word.lowercased() == itemNameLower || 
               itemNameLower.components(separatedBy: " ").contains(word.lowercased()) {
                // Look for a person name before this item
                for i in (0..<index).reversed() {
                    let potentialName = words[i]
                    if potentialName.count > 1 && potentialName.first?.isUppercase == true {
                        return potentialName
                    }
                }
            }
        }
        return nil
    }
    
    private func generateSystemResponse(for input: String) -> String {
        if !unassignedItems.isEmpty {
            let unassignedNames = unassignedItems.map { $0.name }.joined(separator: ", ")
            return "I've processed your input. There are still some unassigned items: \(unassignedNames). Please clarify who should pay for these items."
        } else {
            return "Great! All items have been assigned. Here's your final breakdown."
        }
    }
    
    func resetSession() {
        receipt = nil
        people = []
        conversationHistory = []
        selectedImage = nil
        errorMessage = nil
    }
}

// MARK: - Conversation Models
struct ConversationMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
} 