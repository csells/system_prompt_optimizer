# System Message Optimizer (SMO)

A Dart sample that optimizes system messages for Large Language Models (LLMs)
by automatically adding tool usage guidance, schema compliance rules, and
security guardrails.

## Overview

The System Message Optimizer takes your base system message and enhances it
with:
- Clear tool invocation instructions
- Strict output schema compliance directives  
- Best-practice guardrails for accuracy and safety
- Confidentiality clauses to prevent jailbreaking

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  dartantic_ai: ^0.9.7
```

Then run:
```bash
dart pub get
```

## Usage

```dart
import 'dart:io';
import 'bin/system_prompt_optimizer.dart';

// Define your base system message
final baseSystem = '''
You are a helpful travel agent specializing in vacation planning.
''';

// Provide sample prompts for context
final samplePrompts = [
  'Find me a 3-day itinerary in Kyoto',
  'Book a flight from NYC to Tokyo'
];

// Define tool schemas (optional)
final flightToolSchema = {
  'name': 'searchFlights',
  'description': 'Search for available flights',
  'parameters': {
    'type': 'object',
    'properties': {
      'origin': {'type': 'string', 'description': 'Origin airport code'},
      'destination': {'type': 'string', 'description': 'Destination airport code'},
      'date': {'type': 'string', 'format': 'date'}
    },
    'required': ['origin', 'destination', 'date']
  }
};

// Define output schema (optional)
final outputSchema = {
  'type': 'object',
  'properties': {
    'itinerary': {'type': 'array', 'items': {'type': 'string'}},
    'totalCost': {'type': 'number'}
  },
  'required': ['itinerary']
};

// Optimize the system message
final buffer = StringBuffer();

await for (final chunk in optimizeSystemPrompt(
  baseSystem: baseSystem,
  samplePrompts: samplePrompts,
  toolSchemas: [flightToolSchema],
  outputSchema: outputSchema,
  model: 'google:gemini-2.5-pro',
)) {
  stdout.write(chunk); // Display streaming progress
  buffer.write(chunk);  // Collect complete message
}

final optimizedSystem = buffer.toString();
```

## Running the Demo

```bash
dart run bin/main.dart
```

This will demonstrate the optimizer with a cooking assistant example and save
the result to `optimized_system_message.txt`.

## Running Tests

```bash
# Run all tests
dart test

# Run specific test file
dart test test/smo_test.dart

# Run with verbose output
dart test -r expanded
```

## API Reference

### `optimizeSystemPrompt`

```dart
Stream<String> optimizeSystemPrompt({
  required String baseSystem,
  required List<String> samplePrompts,
  required List<Map<String, dynamic>> toolSchemas,
  Map<String, dynamic>? outputSchema,
  required String model,
})
```

**Parameters:**
- `baseSystem`: Your original system message
- `samplePrompts`: 1-3 example prompts for context (reference only)
- `toolSchemas`: JSON schemas for available tools (can be empty list)
- `outputSchema`: Optional JSON schema for response format
- `model`: LLM model identifier (e.g., 'openai:gpt-4o-mini',
  'google:gemini-2.0-flash')

**Returns:**
- A `Stream<String>` that yields the optimized system message in chunks

## Supported Models

- OpenAI: `openai:gpt-4`, `openai:gpt-4o-mini`, etc.
- Google: `google:gemini-2.0-flash`, `google:gemini-2.5-pro`, etc.
- Any model supported by the `dartantic_ai` package

## Project Structure

```
system_prompt_optimizer/
├── bin/
│   ├── system_prompt_optimizer.dart  # Core SMO implementation
│   └── main.dart                     # Demo application
├── lib/
│   └── system_prompt_optimizer.dart  # Library placeholder
├── test/
│   ├── smo_test.dart                # Main test suite
│   ├── smo_streaming_test.dart      # Streaming tests
│   └── test_helpers.dart            # Test utilities
├── specs/
│   └── design-doc.md                # Detailed design document
└── README.md                        # This file
```

## License

© 2025 Chris Sells. Licensed under MIT.