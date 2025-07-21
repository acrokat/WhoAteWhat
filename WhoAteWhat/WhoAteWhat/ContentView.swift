//
//  ContentView.swift
//  WhoAteWhat
//
//  Created by Kat Kampf on 7/21/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReceiptSplitterViewModel()
    @StateObject private var geminiService = GeminiService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main content
                if viewModel.receipt == nil {
                    // Step 1: Image capture
                    imageCaptureView
                } else if viewModel.people.isEmpty || !viewModel.isReceiptComplete {
                    // Step 2: Conversation/assignment
                    conversationView
                } else {
                    // Step 3: Summary
                    SummaryView(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil || geminiService.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
                geminiService.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage ?? geminiService.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("WhoAteWhat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if viewModel.receipt != nil {
                    Button(action: {
                        viewModel.resetSession()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Progress indicator
            if viewModel.receipt != nil {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    
                    Text("Receipt Analyzed")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    if viewModel.isReceiptComplete {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        
                        Text("Items Assigned")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                        
                        Text("Assigning Items...")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var imageCaptureView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Camera view
            CameraView(selectedImage: $viewModel.selectedImage)
                .padding()
            
            // Instructions
            VStack(spacing: 12) {
                Text("Capture Your Receipt")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Take a clear photo of your receipt or select one from your photo library. Make sure the text is readable for accurate analysis.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Analyze button
            if viewModel.selectedImage != nil {
                Button(action: analyzeReceipt) {
                    HStack {
                        if geminiService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        
                        Text(geminiService.isLoading ? "Analyzing..." : "Analyze Receipt")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(geminiService.isLoading)
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    private var conversationView: some View {
        VStack(spacing: 0) {
            // Receipt items preview
            if let receipt = viewModel.receipt {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Receipt Items")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(receipt.items) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text("$\(String(format: "%.2f", item.price))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6).opacity(0.5))
            }
            
            // Unassigned items warning
            if !viewModel.unassignedItems.isEmpty {
                UnassignedItemsView(unassignedItems: viewModel.unassignedItems) { item in
                    // Handle item assignment
                }
                .padding(.horizontal)
            }
            
            // Conversation
            ConversationView(viewModel: viewModel)
        }
    }
    
    private func analyzeReceipt() {
        guard let image = viewModel.selectedImage else { return }
        
        geminiService.analyzeReceipt(image: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let receipt):
                    viewModel.receipt = receipt
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
