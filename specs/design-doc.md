# System‑Prompt Optimizer (SPO) – Design Document

_Last updated: 08 Jul 2025_

---

## 1. Purpose

The **System‑Prompt Optimizer (SPO)** is a lightweight service that takes a
user‑supplied system message, sample prompts, optional tool schemas, and an
optional typed output schema, and produces a single optimized system message.  
The optimized message preserves the caller's intent while adding clear tooling
directives, schema enforcement rules, and best‑practice guardrails.

## 2. Scope & Goals

* **Accuracy & Compliance** – Ensure downstream LLM responses strictly follow
  the provided output schema and invoke tools correctly.  
* **Flexibility** – Accept arbitrary domain‑specific system messages without
  over‑fitting to the 1–3 example prompts.  
* **Transparency** – Copy tool and output schemas verbatim so the downstream
  model sees exactly what arguments and response structure are required.  
* **Security** – Embed a confidentiality directive to minimize jailbreak risk.  
* **Ease of Integration** – Provide a single Dart function (`optimizeSystemPrompt`)
  that streams the SPO's answer as it's generated.

## 3. Inputs

| Parameter       | Type                        | Required         | Description                                            |
| --------------- | --------------------------- | ---------------- | ------------------------------------------------------ |
| `baseSystem`    | `String`                    | ✅                | Original system message from the user.                 |
| `samplePrompts` | `List<String>`              | ✅ (may be empty) | 1–3 representative prompts (reference only).           |
| `toolSchemas`   | `List<Map<String,dynamic>>` | ✅ (may be empty) | JSON‑schema‑like maps describing each available tool.  |
| `outputSchema`  | `Map<String,dynamic>?`      | Optional         | JSON schema the downstream response **must** satisfy.  |
| `model`         | `String`                    | ✅                | Model identifier for the SPO Agent (e.g. `openai:gpt-4o-mini`). |

## 4. Output

```
Stream<String>
```

The function returns a stream of string chunks that, when concatenated, form the
complete optimized system message. This allows callers to display progress in real-time
or process the output incrementally.

## 5. Architecture

### 5.1 SPO System Message

A static, multi‑rule instruction block that tells the Agent how to:

* Preserve intent and tone from the original base system message
* Insert tool & output schemas verbatim inside fenced `json` blocks  
* Add concrete tool‑usage guidance for when and how to invoke each tool
* Require 100 % schema compliance for structured outputs
* Append a confidentiality clause to prevent system message disclosure
* Add missing best-practice guardrails for accuracy and safety
* Emit only the final optimized system message

The SPO does not modify the schemas themselves - it copies them exactly as provided
and wraps them with appropriate instructions for the downstream LLM.

### 5.2 SPO Prompt Builder

Generates a prompt by splicing caller inputs into labeled sections:

```
BASE_SYSTEM:
...
TOOL_SCHEMAS:
...
OUTPUT_SCHEMA:
...
SAMPLE_PROMPTS:
...
```

The prompt ends with a request for the optimized system message.

### 5.3 Dart Helper – `optimizeSystemPrompt`

```dart
Stream<String> optimizeSystemPrompt({ ... });
```

1. Constructs an `Agent` with:  
   * `system` → static SPO System Message  
   * `prompt` → built prompt from inputs  
2. Returns a stream that yields tokens via `runStream`.  
3. Callers can consume the stream to get the complete optimized system message.

### 5.4 Streaming

Using `Agent.runStream` lets callers surface partial progress or implement their
own token‑level handling with minimal changes.

## 6. Error Handling

At present, the helper:

* Assumes tool and output schemas are syntactically valid JSON‑serializable
  maps.  
* Does not retry or self‑validate the SPO's output; schema validation is
  expected in downstream code if needed.  
* Propagates any SDK/network exceptions to the caller.

Future versions may:

* Add automatic retries on transient failures.  
* Validate the optimized message format before returning.

## 7. Usage Example

```dart
import 'dart:io';
import 'package:system_prompt_optimizer/system_prompt_optimizer.dart';

final buffer = StringBuffer();

await for (final chunk in optimizeSystemPrompt(
  baseSystem: 'You are a helpful travel agent.',
  samplePrompts: ['Find me a 3‑day itinerary in Kyoto'],
  toolSchemas: [flightToolSchema, hotelToolSchema],
  outputSchema: itinerarySchema,
  model: 'openai:gpt-4o-mini',
)) {
  stdout.write(chunk); // Display progress
  buffer.write(chunk); // Collect full message
}

final optimizedSystem = buffer.toString();
```

The resulting string is ready to drop into another `Agent` (or OpenAI completion
call) as its `system` value.

## 8. Flutter Web App Implementation

The SPO Flutter web app (`example/spo_flutter`) provides a user-friendly interface for the System Prompt Optimizer with the following features:

### 8.1 User Experience Enhancements

* **Smart Defaults** – Weather-themed example data helps users understand how the components work together:
  - First sample prompt: "lookup the weather in Boston"
  - Default tool schema: `get_weather` function accepting a location parameter
  - Default output schema: Weather response with temperature and conditions
* **Real-time Validation** – JSON editors validate syntax as you type with visual indicators
* **Responsive Design** – Automatically adapts between desktop (side-by-side) and mobile (tabbed) layouts
* **Persistent Storage** – API keys and form data are encrypted and saved locally using Hive

### 8.2 Technical Implementation

* **State Management** – Uses Provider pattern for reactive UI updates
* **JSON Editing** – Simple TextField with monospace font (removed re_editor due to auto-quote issues)
* **Error Handling** – Graceful handling of JSON parsing errors during typing
* **Platform Support** – Works on Web and macOS (with network entitlements configured)

### 8.3 Security Considerations

* **Encrypted Storage** – API keys are encrypted using AES on native platforms
* **Network Permissions** – macOS entitlements properly configured for API access
* **Input Validation** – All JSON inputs are validated before submission

## 9. Future Improvements

* **Multi‑pass refinement** – Loop until a validator confirms the optimized
  message meets internal quality checks.  
* **Automatic summarization** – Optionally add a short preamble summarizing the
  tool set for easier human audit.  
* **Granular guardrails** – Allow callers to inject custom safety or brand‑tone
  modules.  
* **Caching** – Memoize results for identical input bundles to save tokens and
  latency.
* **Flutter App Enhancements**:
  - Import/export functionality for sharing configurations
  - Multiple saved configurations
  - Dark mode support
  - Advanced JSON editor features (without the auto-quote annoyance)

---

© 2025 Chris Sells. Licensed under MIT.