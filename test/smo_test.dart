import 'package:test/test.dart';

import '../bin/system_prompt_optimizer.dart';

void main() {
  group('System Message Optimizer Tests', () {
    // Test data fixtures
    final baseSystem = 'You are a helpful travel agent.';
    final samplePrompts = [
      'Find me a 3-day itinerary in Kyoto',
      'Book a flight from NYC to Tokyo',
      'Recommend hotels near Mount Fuji',
    ];

    final flightToolSchema = {
      'name': 'searchFlights',
      'description': 'Search for available flights',
      'parameters': {
        'type': 'object',
        'properties': {
          'origin': {'type': 'string', 'description': 'Origin airport code'},
          'destination': {
            'type': 'string',
            'description': 'Destination airport code',
          },
          'date': {
            'type': 'string',
            'format': 'date',
            'description': 'Travel date',
          },
        },
        'required': ['origin', 'destination', 'date'],
      },
    };

    final hotelToolSchema = {
      'name': 'searchHotels',
      'description': 'Search for available hotels',
      'parameters': {
        'type': 'object',
        'properties': {
          'location': {'type': 'string', 'description': 'Hotel location'},
          'checkIn': {'type': 'string', 'format': 'date'},
          'checkOut': {'type': 'string', 'format': 'date'},
          'guests': {'type': 'integer', 'minimum': 1},
        },
        'required': ['location', 'checkIn', 'checkOut'],
      },
    };

    final itinerarySchema = {
      'type': 'object',
      'properties': {
        'destination': {'type': 'string'},
        'duration': {'type': 'integer', 'description': 'Duration in days'},
        'activities': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'day': {'type': 'integer'},
              'description': {'type': 'string'},
              'location': {'type': 'string'},
            },
            'required': ['day', 'description'],
          },
        },
      },
      'required': ['destination', 'duration', 'activities'],
    };

    group('Basic Functionality', () {
      test(
        'optimizeSystem returns OptimizedConfig with optimized message',
        () async {
          final result = await optimizeSystemPrompt(
            baseSystem: baseSystem,
            samplePrompts: [samplePrompts.first],
            toolSchemas: [],
            outputSchema: null,
            model: 'openai:gpt-4o-mini',
          );

          expect(result, isA<OptimizedConfig>());
          expect(result.optimizedSystem, isNotEmpty);
          expect(result.optimizedSystem, contains(baseSystem));
        },
      );

      test('optimizeSystem includes confidentiality directive', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: [samplePrompts.first],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        // Check for security/confidentiality language
        expect(
          result.optimizedSystem.toLowerCase(),
          anyOf(
            contains('confidential'),
            contains('not reveal'),
            contains('do not disclose'),
            contains('keep private'),
            contains('system message'),
          ),
        );
      });
    });

    group('Tool Schema Handling', () {
      test('optimizeSystem includes tool schemas verbatim', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: samplePrompts,
          toolSchemas: [flightToolSchema, hotelToolSchema],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        // Tool schemas should be included as JSON
        expect(result.optimizedSystem, contains('searchFlights'));
        expect(result.optimizedSystem, contains('searchHotels'));
        expect(result.optimizedSystem, contains('```json'));
      });

      test('optimizeSystem handles empty tool schemas', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: [samplePrompts.first],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('optimizeSystem provides tool usage guidance', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: samplePrompts,
          toolSchemas: [flightToolSchema, hotelToolSchema],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        // Should include guidance on how to use tools
        expect(
          result.optimizedSystem.toLowerCase(),
          anyOf(
            contains('tool'),
            contains('function'),
            contains('invoke'),
            contains('call'),
          ),
        );
      });
    });

    group('Output Schema Handling', () {
      test('optimizeSystem includes output schema when provided', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: samplePrompts,
          toolSchemas: [],
          outputSchema: itinerarySchema,
          model: 'openai:gpt-4o-mini',
        );

        // Output schema should be included
        expect(result.optimizedSystem, contains('destination'));
        expect(result.optimizedSystem, contains('duration'));
        expect(result.optimizedSystem, contains('activities'));
        expect(result.optimizedSystem, contains('```json'));
      });

      test('optimizeSystem enforces strict schema compliance', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: samplePrompts,
          toolSchemas: [],
          outputSchema: itinerarySchema,
          model: 'openai:gpt-4o-mini',
        );

        // Should include strict compliance language
        expect(
          result.optimizedSystem.toLowerCase(),
          anyOf(
            contains('must follow'),
            contains('strict'),
            contains('comply'),
            contains('adhere'),
            contains('exactly'),
            contains('100%'),
          ),
        );
      });

      test('optimizeSystem handles null output schema', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: [samplePrompts.first],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });
    });

    group('Sample Prompt Handling', () {
      test('optimizeSystem handles single sample prompt', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: [samplePrompts.first],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('optimizeSystem handles multiple sample prompts', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: samplePrompts, // 3 prompts
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test(
        'optimizeSystem preserves intent without overfitting to samples',
        () async {
          final specificPrompts = [
            'Find flights under \$500',
            'Book economy class only',
            'No layovers please',
          ];

          final result = await optimizeSystemPrompt(
            baseSystem: 'You are a luxury travel consultant.',
            samplePrompts: specificPrompts,
            toolSchemas: [],
            outputSchema: null,
            model: 'openai:gpt-4o-mini',
          );

          // Should maintain luxury focus, not be constrained by economy examples
          expect(result.optimizedSystem, contains('luxury'));
          expect(result.optimizedSystem, isNot(contains('economy class only')));
          expect(result.optimizedSystem, isNot(contains('under \$500')));
        },
      );
    });

    group('Model Support', () {
      test('optimizeSystem works with OpenAI models', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: [samplePrompts.first],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('optimizeSystem works with Google models', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: [samplePrompts.first],
          toolSchemas: [],
          outputSchema: null,
          model: 'google:gemini-2.0-flash',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });
    });

    group('Complex Scenarios', () {
      test('optimizeSystem handles all inputs together', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: baseSystem,
          samplePrompts: samplePrompts,
          toolSchemas: [flightToolSchema, hotelToolSchema],
          outputSchema: itinerarySchema,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);

        // Check all components are present
        expect(result.optimizedSystem, contains(baseSystem));
        expect(result.optimizedSystem, contains('searchFlights'));
        expect(result.optimizedSystem, contains('searchHotels'));
        expect(result.optimizedSystem, contains('destination'));
        expect(result.optimizedSystem, contains('activities'));
      });

      test('optimizeSystem maintains original tone and style', () async {
        final casualSystem =
            'Hey there! I\'m your friendly travel buddy who loves finding cool spots.';

        final result = await optimizeSystemPrompt(
          baseSystem: casualSystem,
          samplePrompts: ['What\'s fun to do in Tokyo?'],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        // Should preserve casual tone
        expect(
          result.optimizedSystem.toLowerCase(),
          anyOf(
            contains('friendly'),
            contains('buddy'),
            contains('cool'),
            contains('hey'),
            contains('fun'),
          ),
        );
      });

      test('optimizeSystem handles technical domain system messages', () async {
        final technicalSystem =
            'You are a Kubernetes deployment specialist focused on high-availability configurations.';

        final result = await optimizeSystemPrompt(
          baseSystem: technicalSystem,
          samplePrompts: ['Configure a 3-node cluster with auto-scaling'],
          toolSchemas: [
            {
              'name': 'deployYaml',
              'description': 'Deploy Kubernetes YAML configuration',
              'parameters': {
                'type': 'object',
                'properties': {
                  'yaml': {'type': 'string'},
                  'namespace': {'type': 'string'},
                },
              },
            },
          ],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result.optimizedSystem, contains('Kubernetes'));
        expect(result.optimizedSystem, contains('high-availability'));
        expect(result.optimizedSystem, contains('deployYaml'));
      });
    });

    group('Edge Cases', () {
      test('optimizeSystem handles very long base system messages', () async {
        final longSystem = '''
You are an expert in multiple domains including but not limited to:
1. Software development across multiple languages and frameworks
2. Cloud architecture and DevOps practices
3. Machine learning and artificial intelligence
4. Database design and optimization
5. Security best practices and threat modeling
6. Project management and agile methodologies
7. Technical documentation and communication
8. Code review and quality assurance
9. Performance optimization and scalability
10. User experience and interface design

Your responses should be detailed, accurate, and tailored to the user's level of expertise.
Always provide examples when possible and cite best practices from industry standards.
        ''';

        final result = await optimizeSystemPrompt(
          baseSystem: longSystem,
          samplePrompts: ['How do I optimize database queries?'],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem.length, greaterThan(longSystem.length));
      });

      test('optimizeSystem handles special characters in inputs', () async {
        final specialSystem = 'You help with math: ∑∏∫ and symbols: α β γ δ';

        final result = await optimizeSystemPrompt(
          baseSystem: specialSystem,
          samplePrompts: ['Calculate ∫(x²)dx'],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('math'));
      });

      test('optimizeSystem handles empty base system gracefully', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: '',
          samplePrompts: ['Do something'],
          toolSchemas: [],
          outputSchema: null,
          model: 'openai:gpt-4o-mini',
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });
    });
  });
}
