//
//  SummaryView.swift
//  WhoAteWhat
//
//  Created by Kat Kampf on 7/21/25.
//

import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: ReceiptSplitterViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Bill Summary")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let receipt = viewModel.receipt {
                        Text("Total: $\(String(format: "%.2f", receipt.total))")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // People breakdown
                ForEach(viewModel.people) { person in
                    PersonSummaryCard(person: person, receipt: viewModel.receipt)
                }
                
                // Total comparison
                if let receipt = viewModel.receipt {
                    TotalComparisonView(
                        calculatedTotal: viewModel.calculatedTotal,
                        receiptTotal: receipt.total
                    )
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Share functionality would go here
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Summary")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        viewModel.resetSession()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Start New Receipt")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
    }
}

struct PersonSummaryCard: View {
    let person: Person
    let receipt: Receipt?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Person name and total
            HStack {
                Text(person.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", person.finalTotal(receipt: receipt)))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // Items list
            if !person.items.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(person.items) { assignedItem in
                        HStack {
                            Text(assignedItem.receiptItem.name)
                                .font(.body)
                            
                            if assignedItem.quantity > 1 {
                                Text("× \(assignedItem.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if assignedItem.sharePercentage < 1.0 {
                                Text("(\(Int(assignedItem.sharePercentage * 100))%)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", assignedItem.totalPrice))")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Breakdown
            VStack(spacing: 4) {
                HStack {
                    Text("Subtotal:")
                    Spacer()
                    Text("$\(String(format: "%.2f", person.totalAmount))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack {
                    Text("Tax:")
                    Spacer()
                    Text("$\(String(format: "%.2f", person.taxAmount(receipt: receipt)))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack {
                    Text("Tip:")
                    Spacer()
                    Text("$\(String(format: "%.2f", person.tipAmount(receipt: receipt)))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct TotalComparisonView: View {
    let calculatedTotal: Double
    let receiptTotal: Double
    
    private var difference: Double {
        abs(calculatedTotal - receiptTotal)
    }
    
    private var isExactMatch: Bool {
        difference < 0.01
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Calculated Total:")
                Spacer()
                Text("$\(String(format: "%.2f", calculatedTotal))")
            }
            
            HStack {
                Text("Receipt Total:")
                Spacer()
                Text("$\(String(format: "%.2f", receiptTotal))")
            }
            
            if !isExactMatch {
                HStack {
                    Text("Difference:")
                    Spacer()
                    Text("$\(String(format: "%.2f", difference))")
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
                
                Text("Note: There's a small discrepancy. Please review your assignments.")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Totals match perfectly!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(isExactMatch ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
} 