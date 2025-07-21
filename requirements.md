# Receipt Splitter iOS App - Product Requirements Document

## 1. Executive Summary

The Receipt Splitter app is an iOS application that allows users to upload receipt images and split bills among multiple people using natural language descriptions. The app leverages Gemini AI to analyze receipts and match items to users based on conversational input, automatically calculating individual totals including proportional tax and tip.

## 2. Product Overview

### 2.1 Core Value Proposition
- Eliminate manual bill splitting calculations
- Support flexible, natural language item assignments
- Automatic tax and tip distribution based on receipt analysis
- Intelligent error detection for missing or unassigned items

### 2.2 Target Users
- Groups dining out together
- People sharing expenses for events or gatherings
- Anyone needing to split itemized bills fairly

## 3. Core Features

### 3.1 Receipt Image Upload & Processing
**Feature**: Camera Integration and Image Processing
- **Requirements**:
  - Native iOS camera integration for receipt capture
  - Photo library access for existing images
  - Support for digital receipts (screenshots, photos of screens)
  - Image preprocessing for optimal AI analysis
  - Error handling for poor image quality with user feedback

**Feature**: Receipt Analysis Engine
- **Requirements**:
  - Integration with Gemini AI API for receipt text extraction
  - Parse receipt data into structured format: items, prices, tax, tip, total
  - Support for USD, EUR, and GBP currencies
  - Automatic currency detection from receipt
  - Handle printed receipts as primary use case
  - Robust error handling for API failures with retry mechanisms

### 3.2 Natural Language Item Assignment
**Feature**: Conversational Input Processing
- **Requirements**:
  - Text input field for natural language descriptions
  - Support flexible phrasing: "Julia got the big beer, Peter got the chicken, we all split the nachos"
  - Parse and extract person names and item associations
  - Handle complex sharing scenarios: "Julia, Kat, Emily, Jordan split the first bottle of wine, but then only Emily, Julia, Kat had the second"
  - Case-insensitive name matching

**Feature**: Dynamic Person Management
- **Requirements**:
  - Automatically detect and add new people from descriptions
  - Allow adding people post-initial-input: "oh and Emily was there and got a glass of rose"
  - Support for nickname/full name variations
  - Person list management within session

### 3.3 Intelligent Item Matching & Validation
**Feature**: AI-Powered Item Assignment
- **Requirements**:
  - Match natural language descriptions to receipt line items
  - Handle fuzzy matching for item descriptions
  - Support shared items with custom distribution
  - Validate all receipt items are assigned to someone

**Feature**: Missing Item Detection
- **Requirements**:
  - Compare receipt items against user assignments
  - Flag unassigned items: "Did you miss XYZ?"
  - Highlight discrepancies between receipt and user input
  - Suggest corrections for potential matches

### 3.4 Conversational Corrections
**Feature**: Chat-Based Editing
- **Requirements**:
  - Follow-up input field for corrections
  - Process correction commands: "no julia got the nachos not peter"
  - Real-time updates to item assignments
  - Maintain conversation history within session
  - Support multiple correction rounds

### 3.5 Financial Calculations
**Feature**: Proportional Cost Distribution
- **Requirements**:
  - Calculate individual item subtotals
  - Apply proportional tax based on individual item costs
  - Apply proportional tip based on individual item costs (using tip percentage from receipt)
  - Round all final amounts to nearest penny
  - Handle shared items with equal or custom distribution

**Feature**: Summary Generation
- **Requirements**:
  - Generate final breakdown table showing:
    - Person name
    - Items assigned
    - Item subtotal
    - Tax amount
    - Tip amount
    - Total amount owed
  - Calculate sum of all individual totals
  - Verify calculated grand total matches receipt total
  - Display discrepancy warning if totals don't match
  - Show both calculated total and receipt total for comparison

### 3.6 User Interface & Experience
**Feature**: Intuitive Workflow
- **Requirements**:
  - Clean, single-screen workflow
  - Clear progress indicators
  - Real-time preview of assignments
  - Easy-to-read final summary table
  - Responsive design for various iPhone screen sizes

**Feature**: Error Handling & User Feedback
- **Requirements**:
  - Clear error messages for network failures
  - Guidance for poor image quality
  - Validation feedback for incomplete assignments
  - Loading states during AI processing
  - Offline detection with appropriate messaging

## 4. Technical Requirements

### 4.1 Platform Specifications
- **Target Platform**: iOS 15.0+
- **Development**: Native iOS (Swift/SwiftUI)
- **Device Support**: iPhone (primary), iPad (secondary)

### 4.2 External Dependencies
- **AI Service**: Google Gemini API for receipt analysis and text processing
- **Image Processing**: iOS native camera and photo library frameworks
- **Network**: URLSession for API communications

### 4.3 Data Management
- **Storage**: No persistent storage (session-based only)
- **Privacy**: No user authentication required
- **Data Handling**: Process images and text locally where possible



## 5. User Flow

### 5.1 Primary User Journey
1. **Image Capture**: User takes photo or selects image of receipt
2. **Receipt Processing**: App analyzes receipt using Gemini AI
3. **Natural Language Input**: User describes who got what in conversational text
4. **Item Assignment**: App matches descriptions to receipt items
5. **Validation**: App flags any missing or unassigned items
6. **Corrections**: User makes corrections via chat-style input
7. **Final Calculation**: App generates breakdown with individual totals
8. **Summary Display**: User sees final bill split table

### 5.2 Error Handling Flows
- **Poor Image Quality**: Prompt user to retake photo
- **Network Failure**: Display retry option with offline indicator
- **Unmatched Items**: Highlight discrepancies and request clarification
- **Parsing Errors**: Provide fallback manual entry options
