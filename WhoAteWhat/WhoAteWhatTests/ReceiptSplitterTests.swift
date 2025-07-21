//
//  ReceiptSplitterTests.swift
//  WhoAteWhatTests
//
//  Created by Kat Kampf on 7/21/25.
//

import XCTest
@testable import WhoAteWhat

final class ReceiptSplitterTests: XCTestCase {
    
    func testReceiptCreation() {
        let items = [
            ReceiptItem(name: "Burger", price: 12.99, quantity: 1),
            ReceiptItem(name: "Fries", price: 4.99, quantity: 1)
        ]
        
        let receipt = Receipt(
            items: items,
            tax: 2.99,
            tip: 4.50,
            total: 25.47,
            currency: "USD"
        )
        
        XCTAssertEqual(receipt.items.count, 2)
        XCTAssertEqual(receipt.total, 25.47)
        XCTAssertEqual(receipt.currency, "USD")
    }
    
    func testPersonAssignment() {
        let viewModel = ReceiptSplitterViewModel()
        
        // Create a receipt
        let receipt = Receipt(
            items: [
                ReceiptItem(name: "Burger", price: 12.99, quantity: 1),
                ReceiptItem(name: "Fries", price: 4.99, quantity: 1)
            ],
            tax: 2.99,
            tip: 4.50,
            total: 25.47,
            currency: "USD"
        )
        
        viewModel.receipt = receipt
        
        // Add a person
        viewModel.addPerson(name: "Julia")
        XCTAssertEqual(viewModel.people.count, 1)
        XCTAssertEqual(viewModel.people.first?.name, "Julia")
        
        // Assign an item
        if let item = receipt.items.first {
            viewModel.assignItemToPerson(item: item, personName: "Julia")
            XCTAssertEqual(viewModel.people.first?.items.count, 1)
        }
    }
    
    func testTaxCalculation() {
        let person = Person(name: "Julia")
        let item = ReceiptItem(name: "Burger", price: 12.99, quantity: 1)
        let assignedItem = AssignedItem(receiptItem: item, quantity: 1, sharePercentage: 1.0)
        
        var personWithItem = person
        personWithItem.items = [assignedItem]
        
        let receipt = Receipt(
            items: [item],
            tax: 2.99,
            tip: 4.50,
            total: 20.48,
            currency: "USD"
        )
        
        let taxAmount = personWithItem.taxAmount(receipt: receipt)
        XCTAssertEqual(taxAmount, 2.99, accuracy: 0.01)
    }
    
    func testNaturalLanguageProcessing() {
        let viewModel = ReceiptSplitterViewModel()
        
        // Create a receipt
        let receipt = Receipt(
            items: [
                ReceiptItem(name: "Burger", price: 12.99, quantity: 1),
                ReceiptItem(name: "Fries", price: 4.99, quantity: 1)
            ],
            tax: 2.99,
            tip: 4.50,
            total: 25.47,
            currency: "USD"
        )
        
        viewModel.receipt = receipt
        
        // Test natural language input
        viewModel.processNaturalLanguageInput("Julia got the burger")
        
        XCTAssertEqual(viewModel.people.count, 1)
        XCTAssertEqual(viewModel.people.first?.name, "Julia")
        XCTAssertEqual(viewModel.people.first?.items.count, 1)
    }
} 