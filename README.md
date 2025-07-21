# WhoAteWhat - Receipt Splitter iOS App

A modern iOS app that uses AI to analyze receipts and split bills among multiple people using natural language descriptions.

## Features

- 📸 **Camera Integration**: Capture receipt images or select from photo library
- 🤖 **AI-Powered Analysis**: Uses Google Gemini AI to extract receipt data
- 💬 **Natural Language Input**: Describe who got what in conversational text
- 🧮 **Automatic Calculations**: Proportional tax and tip distribution
- 📊 **Smart Validation**: Detects missing or unassigned items
- 💰 **Final Summary**: Clean breakdown with individual totals

## Setup Instructions

### 1. Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ deployment target
- Google Gemini API key

### 2. API Key Configuration
1. Get a Google Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Open `WhoAteWhat/GeminiService.swift`
3. Replace `"YOUR_GEMINI_API_KEY"` with your actual API key

### 3. Build and Run
1. Open `WhoAteWhat.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

## Usage

### Step 1: Capture Receipt
- Tap the camera button to take a photo or select from library
- Ensure the receipt text is clear and readable
- Tap "Analyze Receipt" to process with AI

### Step 2: Assign Items
- Use natural language to describe who got what
- Examples:
  - "Julia got the burger, Peter got the fries"
  - "We all split the nachos"
  - "Emily and Kat shared the wine"
- The app will automatically detect people and match items

### Step 3: Review and Complete
- Check for any unassigned items
- Make corrections using the chat interface
- View the final breakdown with individual totals

## Technical Architecture

### Core Components
- **Models.swift**: Data structures for receipts, people, and items
- **GeminiService.swift**: AI integration for receipt analysis
- **ImagePicker.swift**: Camera and photo library functionality
- **ConversationView.swift**: Natural language input interface
- **SummaryView.swift**: Final bill breakdown display
- **ContentView.swift**: Main app workflow coordination

### Key Features
- **MVVM Architecture**: Clean separation of concerns
- **SwiftUI**: Modern declarative UI framework
- **Async/Await**: Modern concurrency for API calls
- **Error Handling**: Comprehensive error management
- **Accessibility**: Built-in iOS accessibility support

## Privacy & Security

- No user authentication required
- Images processed locally where possible
- No persistent storage of receipt data
- Session-based processing only

## Troubleshooting

### Common Issues
1. **Camera not working**: Check Info.plist permissions
2. **API errors**: Verify Gemini API key is correct
3. **Build errors**: Ensure iOS 15.0+ deployment target

### Debug Mode
The app includes sample receipt data for testing without API calls. See `GeminiService.swift` for details.

## Contributing

This is a demo implementation. For production use, consider:
- Enhanced NLP for better item matching
- Offline receipt processing
- Data persistence options
- Enhanced error recovery
- Multi-currency support

## License

This project is for educational and demonstration purposes.