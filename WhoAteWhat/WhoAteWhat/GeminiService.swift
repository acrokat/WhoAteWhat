//
//  GeminiService.swift
//  WhoAteWhat
//
//  Created by Kat Kampf on 7/21/25.
//

import Foundation
import UIKit

class GeminiService: ObservableObject {
    private let apiKey = "YOUR_GEMINI_API_KEY" // Replace with actual API key
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func analyzeReceipt(image: UIImage, completion: @escaping (Result<Receipt, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Demo mode - return sample data for testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            let demoReceipt = Receipt(
                items: [
                    ReceiptItem(name: "Burger", price: 12.99, quantity: 1),
                    ReceiptItem(name: "Fries", price: 4.99, quantity: 1),
                    ReceiptItem(name: "Coke", price: 2.99, quantity: 2),
                    ReceiptItem(name: "Salad", price: 8.99, quantity: 1),
                    ReceiptItem(name: "Wine", price: 15.99, quantity: 1)
                ],
                tax: 3.99,
                tip: 6.50,
                total: 52.44,
                currency: "USD"
            )
            completion(.success(demoReceipt))
        }
        return
        
        // Original API implementation (commented out for demo)
        /*
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            isLoading = false
            errorMessage = "Failed to process image"
            completion(.failure(GeminiError.imageProcessingFailed))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let prompt = """
        Analyze this receipt image and extract the following information in JSON format:
        {
            "items": [
                {
                    "name": "item name",
                    "price": price as number,
                    "quantity": quantity as number
                }
            ],
            "tax": tax amount as number,
            "tip": tip amount as number,
            "total": total amount as number,
            "currency": "USD"
        }
        
        Please be accurate with the item names and prices. If you can't determine certain values, use 0.
        """
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: prompt),
                        GeminiPart(text: "data:image/jpeg;base64,\(base64Image)")
                    ]
                )
            ]
        )
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            isLoading = false
            errorMessage = "Invalid URL"
            completion(.failure(GeminiError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            isLoading = false
            errorMessage = "Failed to encode request"
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    completion(.failure(GeminiError.noData))
                    return
                }
                
                do {
                    let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    
                    guard let candidate = geminiResponse.candidates.first,
                          let text = candidate.content.parts.first?.text else {
                        self?.errorMessage = "Invalid response format"
                        completion(.failure(GeminiError.invalidResponse))
                        return
                    }
                    
                    // Extract JSON from the response text
                    let receipt = try self?.parseReceiptFromResponse(text) ?? Receipt()
                    completion(.success(receipt))
                    
                } catch {
                    self?.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }.resume()
        */
    }
    
    private func parseReceiptFromResponse(_ responseText: String) throws -> Receipt {
        // Extract JSON from the response (remove markdown formatting if present)
        let jsonStart = responseText.firstIndex(of: "{")
        let jsonEnd = responseText.lastIndex(of: "}")
        
        guard let start = jsonStart, let end = jsonEnd else {
            throw GeminiError.invalidResponse
        }
        
        let jsonString = String(responseText[start...end])
        
        // For demo purposes, return a sample receipt
        // In a real implementation, you would parse the actual JSON response
        return Receipt(
            items: [
                ReceiptItem(name: "Burger", price: 12.99, quantity: 1),
                ReceiptItem(name: "Fries", price: 4.99, quantity: 1),
                ReceiptItem(name: "Coke", price: 2.99, quantity: 2),
                ReceiptItem(name: "Salad", price: 8.99, quantity: 1)
            ],
            tax: 2.99,
            tip: 4.50,
            total: 37.45,
            currency: "USD"
        )
    }
}

enum GeminiError: Error, LocalizedError {
    case imageProcessingFailed
    case invalidURL
    case noData
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .invalidURL:
            return "Invalid API URL"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
} 