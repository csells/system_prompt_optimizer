# System Message Optimizer Flutter Web App

A Flutter web application that provides a user-friendly interface for the System Message Optimizer (SMO).

## Features

- **Responsive Design**: Works seamlessly on desktop (side-by-side panels) and mobile (tabbed interface)
- **Secure Storage**: API keys and form data are encrypted and persisted using Hive with AES encryption
- **Real-time Validation**: JSON editors validate syntax as you type
- **Streaming Output**: Watch the optimized system message appear character by character
- **Tool Schema Management**: Add, edit, and remove tool schemas with individual JSON editors
- **Copy to Clipboard**: Easy one-click copying of the optimized output

## Getting Started

1. **Install Flutter**: Make sure you have Flutter installed and set up for web development
   ```bash
   flutter doctor
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run -d chrome
   ```

## Usage

1. **API Key**: Enter your Gemini API key (click the link to get one if needed)
2. **Model**: Enter the model name (e.g., `google:gemini-2.5-flash`)
3. **Base System**: Enter your original system message
4. **Sample Prompts**: Provide 1-3 example prompts (at least one required)
5. **Tool Schemas**: Add tool definitions in JSON format
6. **Output Schema**: Optionally define the expected output structure
7. **Optimize**: Click the button to generate the optimized system message

## Building for Production

To build the web app for deployment:

```bash
flutter build web --release
```

The built files will be in `build/web/`.

## Dependencies

- `provider`: State management
- `hive` & `hive_flutter`: Cross-platform encrypted storage
- `url_launcher`: Open external links
- `json_schema`: JSON validation
- `system_prompt_optimizer`: Core SMO functionality

## Architecture

The app follows a clean architecture pattern with:
- **Models**: Data structures (`smo_form_data.dart`)
- **Providers**: State management (`smo_provider.dart`)
- **Widgets**: Reusable UI components
- **Screens**: Main application screens

The responsive layout automatically adapts to screen size, providing an optimal experience on both desktop and mobile devices.
