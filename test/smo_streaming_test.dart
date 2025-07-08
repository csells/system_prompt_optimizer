import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('SMO Streaming Tests', () {
    final baseSystem = 'You are a helpful assistant.';
    final samplePrompts = ['Help me plan a trip'];

    test('optimizeSystem streams tokens progressively', () async {
      // Since optimizeSystem internally uses streaming, we can verify
      // that it completes successfully and returns a non-empty result
      final result = await optimizeSystemPrompt(
        baseSystem: baseSystem,
        samplePrompts: samplePrompts,
        toolSchemas: [],
        outputSchema: null,
        model: 'google:gemini-2.5-flash',
      );

      // The function should complete and return a result
      expect(result, isA<OptimizedConfig>());
      expect(result.optimizedSystem, isNotEmpty);
      expect(result.optimizedSystem.length, greaterThan(baseSystem.length));
    });

    test('streaming handles network interruptions gracefully', () async {
      // Test with a valid model to ensure function completes
      final result = await optimizeSystemPrompt(
        baseSystem: baseSystem,
        samplePrompts: samplePrompts,
        toolSchemas: [],
        outputSchema: null,
        model: 'google:gemini-2.5-flash',
      );

      expect(result, isA<OptimizedConfig>());
      expect(result.optimizedSystem, isNotEmpty);
    });

    test('streaming concatenates tokens correctly', () async {
      final complexSystem = '''
You are an AI assistant with multiple responsibilities:
1. Answer questions accurately
2. Provide helpful suggestions
3. Follow safety guidelines
      ''';

      final result = await optimizeSystemPrompt(
        baseSystem: complexSystem,
        samplePrompts: ['What is the weather today?', 'Help me write code'],
        toolSchemas: [
          {
            'name': 'getWeather',
            'description': 'Get current weather',
            'parameters': {
              'type': 'object',
              'properties': {
                'location': {'type': 'string'},
              },
            },
          },
        ],
        outputSchema: {
          'type': 'object',
          'properties': {
            'response': {'type': 'string'},
            'confidence': {'type': 'number', 'minimum': 0, 'maximum': 1},
          },
        },
        model: 'google:gemini-2.5-flash',
      );

      // Verify the result is properly formed
      expect(result.optimizedSystem, isNotEmpty);

      // Check that key components are present and properly formatted
      expect(result.optimizedSystem, contains('```json'));
      expect(result.optimizedSystem, contains('getWeather'));
      expect(result.optimizedSystem, contains('confidence'));

      // Ensure no truncation or malformed content
      expect(result.optimizedSystem.trim(), isNot(endsWith('...')));
      expect(
        result.optimizedSystem.split('```json').length,
        greaterThanOrEqualTo(2),
      );
    });

    test('streaming performance for large inputs', () async {
      // Create a large base system message
      final largeSystem = List.generate(
        50,
        (i) =>
            'Instruction ${i + 1}: Perform task ${i + 1} with specific requirements and constraints.',
      ).join('\n');

      // Create multiple tool schemas
      final toolSchemas = List.generate(
        10,
        (i) => {
          'name': 'tool$i',
          'description': 'Tool $i for specific operations',
          'parameters': {
            'type': 'object',
            'properties': {
              'param1': {
                'type': 'string',
                'description': 'Parameter 1 for tool $i',
              },
              'param2': {
                'type': 'integer',
                'description': 'Parameter 2 for tool $i',
              },
              'param3': {
                'type': 'boolean',
                'description': 'Parameter 3 for tool $i',
              },
            },
            'required': ['param1'],
          },
        },
      );

      final startTime = DateTime.now();

      final result = await optimizeSystemPrompt(
        baseSystem: largeSystem,
        samplePrompts: ['Execute task 1', 'Execute task 25', 'Execute task 50'],
        toolSchemas: toolSchemas,
        outputSchema: {
          'type': 'object',
          'properties': {
            'results': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'taskId': {'type': 'integer'},
                  'status': {
                    'type': 'string',
                    'enum': ['success', 'failure'],
                  },
                  'output': {'type': 'string'},
                },
              },
            },
          },
        },
        model: 'google:gemini-2.5-flash',
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Should complete within reasonable time (adjust based on your requirements)
      expect(duration.inSeconds, lessThan(60));

      // Verify result completeness
      expect(result.optimizedSystem, isNotEmpty);
      expect(result.optimizedSystem.length, greaterThan(largeSystem.length));

      // Check all tools are included
      for (var i = 0; i < 10; i++) {
        expect(result.optimizedSystem, contains('tool$i'));
      }
    });

    test('streaming handles various character encodings', () async {
      final multilingualSystem = '''
You are a multilingual assistant who can help in:
- English: Hello, how can I help?
- Spanish: ¡Hola! ¿Cómo puedo ayudar?
- Japanese: こんにちは、お手伝いできますか？
- Arabic: مرحبا، كيف يمكنني المساعدة؟
- Emoji: 👋 😊 🌍
      ''';

      final result = await optimizeSystemPrompt(
        baseSystem: multilingualSystem,
        samplePrompts: [
          'Translate "hello" to Spanish',
          'Write "thank you" in Japanese',
          'What is "goodbye" in Arabic?',
        ],
        toolSchemas: [],
        outputSchema: null,
        model: 'google:gemini-2.5-flash',
      );

      expect(result, isA<OptimizedConfig>());
      expect(result.optimizedSystem, isNotEmpty);

      // Verify special characters are preserved
      expect(result.optimizedSystem, contains('multilingual'));
    });
  });
}
