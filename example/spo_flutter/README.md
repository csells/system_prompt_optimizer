# System Prompt Optimizer Flutter Web App

A Flutter web application that provides a user-friendly interface for the System Prompt Optimizer (SPO).

## Features

- **Responsive Design**: Works seamlessly on desktop (side-by-side panels) and mobile (tabbed interface)
- **Secure Storage**: API keys and form data are encrypted and persisted using Hive with AES encryption
- **Real-time Validation**: JSON editors validate syntax as you type with clear error/success indicators
- **Streaming Output**: Watch the optimized system message appear character by character
- **Tool Schema Management**: Add, edit, and remove tool schemas with individual JSON editors
- **Smart Defaults**: Weather-themed example schemas help you get started quickly
- **Copy to Clipboard**: Easy one-click copying of the optimized output
- **Cross-Platform**: Works on Web, macOS, and other Flutter-supported platforms

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
   # For web
   flutter run -d chrome
   
   # For macOS (requires network entitlements)
   flutter run -d macos
   ```

## Usage

1. **API Key**: Enter your Gemini API key (click the link to get one if needed)
2. **Model**: Enter the model name (e.g., `google:gemini-2.5-flash`)
3. **Base System**: Enter your original system message
4. **Sample Prompts**: Add example prompts - the first defaults to "lookup the weather in Boston"
5. **Tool Schemas**: Click "Add Tool" to create a weather lookup tool with example parameters
6. **Output Schema**: Click "Add Output Schema" to define structured output (defaults to weather data)
7. **Optimize**: Click the button to generate the optimized system message

### Example Workflow
The app includes cohesive weather-themed defaults to help you understand how the pieces work together:
- Sample prompt: "lookup the weather in Boston"
- Tool schema: `get_weather` function that accepts a location
- Output schema: Structured response with temperature and conditions

## Building for Production

To build the web app for deployment:

```bash
flutter build web --release
```

The built files will be in `build/web/`.

## Platform-Specific Notes

### macOS
The macOS app requires network permissions to make API calls. The entitlements files have been configured with:
- `com.apple.security.network.client`: Allows outgoing network connections

### Web
The web version stores data in browser local storage using Hive (without encryption due to web limitations).

## Dependencies

- `provider`: State management
- `hive` & `hive_flutter`: Cross-platform encrypted storage
- `url_launcher`: Open external links
- `json_schema`: JSON validation
- `system_prompt_optimizer`: Core SPO functionality

## Architecture

The app follows a clean architecture pattern with:
- **Models**: Data structures (`spo_form_data.dart`)
- **Providers**: State management (`spo_provider.dart`)
- **Widgets**: Reusable UI components
- **Screens**: Main application screens

The responsive layout automatically adapts to screen size, providing an optimal experience on both desktop and mobile devices.
