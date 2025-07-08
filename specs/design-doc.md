# System‑Message Optimizer (SMO) – Design Document

_Last updated: 08 Jul 2025_

---

## 1. Purpose

The **System‑Message Optimizer (SMO)** is a lightweight service that takes a
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
  that streams the SMO's answer as it's generated.

## 3. Inputs

| Parameter       | Type                        | Required         | Description                                            |
| --------------- | --------------------------- | ---------------- | ------------------------------------------------------ |
| `baseSystem`    | `String`                    | ✅                | Original system message from the user.                 |
| `samplePrompts` | `List<String>`              | ✅                | 1–3 representative prompts (reference only).           |
| `toolSchemas`   | `List<Map<String,dynamic>>` | ✅ (may be empty) | JSON‑schema‑like maps describing each available tool.  |
| `outputSchema`  | `Map<String,dynamic>?`      | Optional         | JSON schema the downstream response **must** satisfy.  |
| `model`         | `String`                    | ✅                | Model identifier for the SMO Agent (e.g. `openai:gpt-4o-mini`). |

## 4. Output

```
Stream<String>
```

The function returns a stream of string chunks that, when concatenated, form the
complete optimized system message. This allows callers to display progress in real-time
or process the output incrementally.

## 5. Architecture

### 5.1 SMO System Message

A static, multi‑rule instruction block that tells the Agent how to:

* Preserve intent and tone  
* Insert tool & output schemas verbatim inside fenced `json` blocks  
* Add concrete tool‑usage guidance  
* Require 100 % schema compliance  
* Append a confidentiality clause  
* Emit only the final system message

### 5.2 SMO Prompt Builder

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
   * `system` → static SMO System Message  
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
* Does not retry or self‑validate the SMO's output; schema validation is
  expected in downstream code if needed.  
* Propagates any SDK/network exceptions to the caller.

Future versions may:

* Add automatic retries on transient failures.  
* Validate the optimized message format before returning.

## 7. Usage Example

```dart
import 'dart:io';

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

## 8. Future Improvements

* **Multi‑pass refinement** – Loop until a validator confirms the optimized
  message meets internal quality checks.  
* **Automatic summarization** – Optionally add a short preamble summarizing the
  tool set for easier human audit.  
* **Granular guardrails** – Allow callers to inject custom safety or brand‑tone
  modules.  
* **Caching** – Memoize results for identical input bundles to save tokens and
  latency.

---

© 2025 Chris Sells. Licensed under MIT.