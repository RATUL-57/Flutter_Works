# ai_chat_bot

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# AI ChatBot

This project is a basic AI chatbot application built with Flutter. It allows users to interact with an AI model through a chat interface, displaying AI responses and user inputs in a visually distinct manner. The application also supports rendering code snippets in markdown format.

## Project Structure

```
ai_chat_bot
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── pages
│   │   ├── intro_page.dart      # Introductory page with a "Start Chat" button
│   │   └── chat_page.dart       # Chat interface for user interactions
│   ├── widgets
│   │   ├── chat_bubble.dart     # Widget for displaying chat messages
│   │   └── markdown_display.dart # Widget for rendering markdown content
│   ├── models
│   │   └── message.dart         # Model class for chat messages
│   └── services
│       └── api_service.dart     # Service for handling API calls
├── pubspec.yaml                 # Flutter configuration file
└── README.md                    # Project documentation
```

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd ai_chat_bot
   ```

2. **Install dependencies:**
   Run the following command to install the required packages:
   ```
   flutter pub get
   ```

3. **Run the application:**
   Use the following command to start the application:
   ```
   flutter run
   ```

## Usage

- Upon launching the app, you will see an introductory page with the title "AI ChatBot" and a "Start Chat" button.
- Clicking the "Start Chat" button will navigate you to the chat interface.
- In the chat interface, you can send messages to the AI, and the responses will be displayed accordingly.
- Code snippets in the AI responses will be rendered in markdown format for better readability.

## Dependencies

This project uses the following dependencies:
- `http`: For making API requests.
- `flutter_markdown`: For rendering markdown content.

Feel free to explore and modify the code to enhance the chatbot's functionality!