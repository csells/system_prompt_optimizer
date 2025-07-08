# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dart command-line application for optimizing system prompts for Large Language Models (LLMs). The System Message Optimizer (SMO) takes a base system message and enhances it with best practices, tool schemas, and output formatting requirements.

## Commands

### Development Commands
```bash
# Install dependencies
dart pub get

# Run tests
dart test

# Run static analysis
dart analyze

# Run a specific test file
dart test test/system_prompt_optimizer_test.dart
```

### Missing Setup
**Important**: The project requires the `dartantic_ai` package (≥ 0.6.0) which is not currently listed in pubspec.yaml. Add it before running:
```yaml
dependencies:
  dartantic_ai: ^0.6.0
```

## Architecture

### Core Functionality
The main implementation is in `bin/system_prompt_optimizer.dart`, which provides:
- `optimizeSystem()` function that accepts:
  - `baseSystem`: Base system message to optimize
  - `samplePrompts`: Example prompts for style reference
  - `toolSchemas`: JSON schemas for available tools
  - `outputSchema`: Optional output format schema
  - `model`: LLM model identifier (e.g., 'openai:o3', 'google:gemini-2.5-pro')
- Returns an `OptimizedConfig` containing the enhanced system message

### Project Structure
- `/bin/` - Main SMO implementation (system_prompt_optimizer.dart)
- `/lib/` - Library code (currently contains placeholder code)
- `/test/` - Unit tests (currently only tests placeholder functionality)

### Key Design Principles
1. The optimizer adds guardrails for accuracy, safety, and content moderation
2. Ensures structured output compliance when schemas are provided
3. Maintains confidentiality of the system message
4. Supports multiple LLM providers through the dartantic_ai package

## Current State Notes
- The main functionality exists but lacks a CLI entry point with a main() function
- Tests need to be written for the actual SMO functionality
- The library file contains only placeholder code
- Documentation is minimal beyond code comments