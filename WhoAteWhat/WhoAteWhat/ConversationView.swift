//
//  ConversationView.swift
//  WhoAteWhat
//
//  Created by Kat Kampf on 7/21/25.
//

import SwiftUI

struct ConversationView: View {
    @ObservedObject var viewModel: ReceiptSplitterViewModel
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Conversation history
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.conversationHistory) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.conversationHistory.count) { _ in
                    if let lastMessage = viewModel.conversationHistory.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    TextField("Describe who got what...", text: $inputText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputFocused)
                        .lineLimit(1...3)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .onAppear {
            // Add welcome message if conversation is empty
            if viewModel.conversationHistory.isEmpty {
                let welcomeMessage = ConversationMessage(
                    text: "Hi! I've analyzed your receipt. Now tell me who got what in natural language. For example: 'Julia got the burger, Peter got the fries, and we all split the nachos.'",
                    isUser: false
                )
                viewModel.conversationHistory.append(welcomeMessage)
            }
        }
    }
    
    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        viewModel.processNaturalLanguageInput(trimmedText)
        inputText = ""
        isInputFocused = false
    }
}

struct MessageBubble: View {
    let message: ConversationMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                Spacer()
            }
        }
    }
}

struct UnassignedItemsView: View {
    let unassignedItems: [ReceiptItem]
    let onAssignItem: (ReceiptItem) -> Void
    
    var body: some View {
        if !unassignedItems.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Unassigned Items")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                ForEach(unassignedItems) { item in
                    HStack {
                        Text(item.name)
                            .font(.body)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", item.price))")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Assign") {
                            onAssignItem(item)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
} 