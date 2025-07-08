import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('SMO Edge Cases and Boundary Tests', () {
    const testModel = 'gemini:gemini-2.5-flash';

    group('Empty and Minimal Inputs', () {
      test('handles empty baseSystem', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: '',
          samplePrompts: ['Do something'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('handles whitespace-only baseSystem', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: '   \n\t  ',
          samplePrompts: ['Help with task'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('handles single-word baseSystem', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'Assistant',
          samplePrompts: ['Help'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem.toLowerCase(), contains('assistant'));
      });

      test('handles empty sample prompts list', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a helpful assistant.',
          samplePrompts: [],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('handles single empty sample prompt', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a helpful assistant.',
          samplePrompts: [''],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('handles whitespace-only sample prompts', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a helpful assistant.',
          samplePrompts: ['   ', '\n\t', '  \n  '],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });
    });

    group('Large Inputs', () {
      test('handles very long baseSystem', () async {
        final longSystem = List.generate(
          100,
          (i) =>
              'You are an expert assistant with deep knowledge in domain $i.',
        ).join(' ');

        final result = await optimizeSystemPrompt(
          baseSystem: longSystem,
          samplePrompts: ['Help me with a complex task'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
        // The optimized system should contain references to the original content
        expect(result.optimizedSystem, contains('expert'));
        expect(result.optimizedSystem, contains('assistant'));
      });

      test('handles many sample prompts', () async {
        final manyPrompts = List.generate(
          10,
          (i) => 'Sample prompt number ${i + 1} with specific requirements.',
        );

        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a helpful assistant.',
          samplePrompts: manyPrompts,
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('handles large number of tool schemas', () async {
        final manyTools = List.generate(
          8,
          (i) => {
            'name': 'tool$i',
            'description':
                'Tool $i for specific operations with many parameters',
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
                'param4': {
                  'type': 'array',
                  'items': {'type': 'string'},
                  'description': 'Parameter 4 for tool $i',
                },
              },
              'required': ['param1', 'param2'],
            },
          },
        );

        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a multi-tool assistant.',
          samplePrompts: ['Use tools to help me'],
          toolSchemas: manyTools,
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
        // Should contain references to multiple tools
        expect(result.optimizedSystem, contains('tool0'));
        expect(result.optimizedSystem, contains('tool7'));
      });

      test('handles deeply nested output schema', () async {
        final complexSchema = {
          'type': 'object',
          'properties': {
            'level1': {
              'type': 'object',
              'properties': {
                'level2': {
                  'type': 'object',
                  'properties': {
                    'level3': {
                      'type': 'object',
                      'properties': {
                        'level4': {
                          'type': 'array',
                          'items': {
                            'type': 'object',
                            'properties': {
                              'deepField': {'type': 'string'},
                              'deepArray': {
                                'type': 'array',
                                'items': {
                                  'type': 'object',
                                  'properties': {
                                    'veryDeep': {'type': 'string'},
                                  },
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          'required': ['level1'],
        };

        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a structured data assistant.',
          samplePrompts: ['Generate complex nested data'],
          toolSchemas: [],
          outputSchema: complexSchema,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('level1'));
        expect(result.optimizedSystem, contains('deepField'));
      });
    });

    group('Special Characters and Unicode', () {
      test('handles Unicode characters in baseSystem', () async {
        final unicodeSystem = '''
You are a multilingual assistant: 
- English: Hello! 👋
- Japanese: こんにちは！🇯🇵  
- Arabic: مرحبا! 🇸🇦
- Emoji: 🤖💬🌍
- Math: ∑∏∫ α β γ δ
- Special: «»""''—–…
''';

        final result = await optimizeSystemPrompt(
          baseSystem: unicodeSystem,
          samplePrompts: ['Help me with translations 🔤'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('multilingual'));
        expect(result.optimizedSystem, contains('🤖'));
      });

      test('handles special characters in sample prompts', () async {
        final specialPrompts = [
          'Calculate ∫(x²)dx from 0 to ∞',
          'JSON: {"key": "value", "nested": {"array": [1,2,3]}}',
          'Code: function test() { return "hello"; }',
          'Symbols: @#\$%^&*()_+-=[]{}|;:\'",.<>?/',
          'Quotes: "smart" \'quotes\' «guillemets» „german"',
        ];

        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a technical assistant.',
          samplePrompts: specialPrompts,
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('handles newlines and whitespace in all fields', () async {
        final multilineSystem = '''
You are a helpful assistant.
You should:
  1. Be helpful
  2. Be accurate
  3. Be concise

Remember:
- Always double-check your work
- Ask for clarification when needed
''';

        final multilinePrompts = [
          '''
Can you help me with:
- Task 1
- Task 2
- Task 3
''',
          'Single line prompt',
          '''
Multi-line
prompt with
various formatting
''',
        ];

        final result = await optimizeSystemPrompt(
          baseSystem: multilineSystem,
          samplePrompts: multilinePrompts,
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });
    });

    group('Schema Edge Cases', () {
      test('handles tool schema with no parameters', () async {
        final simpleTools = [
          {
            'name': 'ping',
            'description': 'Simple ping tool with no parameters',
            'parameters': {'type': 'object', 'properties': {}},
          },
          {
            'name': 'status',
            'description': 'Get system status',
            'parameters': {'type': 'object'},
          },
        ];

        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a system monitoring assistant.',
          samplePrompts: ['Check system status'],
          toolSchemas: simpleTools,
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('ping'));
        expect(result.optimizedSystem, contains('status'));
      });

      test('handles output schema with only primitives', () async {
        final primitiveSchema = {
          'type': 'object',
          'properties': {
            'text': {'type': 'string'},
            'number': {'type': 'number'},
            'integer': {'type': 'integer'},
            'boolean': {'type': 'boolean'},
            'null_field': {'type': 'null'},
          },
          'required': ['text', 'number'],
        };

        final result = await optimizeSystemPrompt(
          baseSystem: 'You return structured primitive data.',
          samplePrompts: ['Give me some data'],
          toolSchemas: [],
          outputSchema: primitiveSchema,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('string'));
        expect(result.optimizedSystem, contains('number'));
        expect(result.optimizedSystem, contains('boolean'));
      });

      test('handles empty output schema', () async {
        final emptySchema = {'type': 'object', 'properties': {}};

        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a minimal assistant.',
          samplePrompts: ['Help'],
          toolSchemas: [],
          outputSchema: emptySchema,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });
    });

    group('All Combinations', () {
      test('absolutely minimal valid input', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'A',
          samplePrompts: ['B'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
        expect(result.optimizedSystem.length, greaterThan(2));
      });

      test('everything empty except required fields', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: '',
          samplePrompts: [],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('tools but no output schema', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a tool-using assistant.',
          samplePrompts: ['Use tools to help'],
          toolSchemas: [
            {
              'name': 'search',
              'description': 'Search for information',
              'parameters': {
                'type': 'object',
                'properties': {
                  'query': {'type': 'string'},
                },
                'required': ['query'],
              },
            },
          ],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('search'));
        expect(result.optimizedSystem, contains('query'));
      });

      test('output schema but no tools', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You return structured data.',
          samplePrompts: ['Give me structured output'],
          toolSchemas: [],
          outputSchema: {
            'type': 'object',
            'properties': {
              'result': {'type': 'string'},
              'confidence': {'type': 'number'},
            },
            'required': ['result'],
          },
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('result'));
        expect(result.optimizedSystem, contains('confidence'));
      });

      test('maximum everything - complex realistic scenario', () async {
        final complexSystem = '''
You are an advanced AI assistant specialized in data analysis, visualization, 
and reporting. You have expertise in statistics, machine learning, and business 
intelligence. You can process various data formats and generate comprehensive 
insights with visual representations.
''';

        final complexPrompts = [
          'Analyze sales data from Q1-Q4 and create visualizations',
          'Generate a predictive model for customer churn',
          'Create a dashboard showing KPIs and trends',
          'Export findings to PDF with charts and tables',
        ];

        final complexTools = [
          {
            'name': 'analyzeData',
            'description': 'Analyze dataset and return statistical insights',
            'parameters': {
              'type': 'object',
              'properties': {
                'dataset': {'type': 'string', 'description': 'Path to dataset'},
                'metrics': {
                  'type': 'array',
                  'items': {'type': 'string'},
                  'description': 'Metrics to calculate',
                },
                'groupBy': {
                  'type': 'array',
                  'items': {'type': 'string'},
                  'description': 'Columns to group by',
                },
              },
              'required': ['dataset'],
            },
          },
          {
            'name': 'createVisualization',
            'description': 'Create charts and graphs',
            'parameters': {
              'type': 'object',
              'properties': {
                'data': {'type': 'object', 'description': 'Data to visualize'},
                'chartType': {
                  'type': 'string',
                  'enum': ['bar', 'line', 'pie', 'scatter', 'heatmap'],
                },
                'title': {'type': 'string'},
                'xAxis': {'type': 'string'},
                'yAxis': {'type': 'string'},
              },
              'required': ['data', 'chartType'],
            },
          },
        ];

        final complexSchema = {
          'type': 'object',
          'properties': {
            'analysis': {
              'type': 'object',
              'properties': {
                'summary': {'type': 'string'},
                'insights': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'metrics': {
                  'type': 'object',
                  'properties': {
                    'mean': {'type': 'number'},
                    'median': {'type': 'number'},
                    'stdDev': {'type': 'number'},
                  },
                },
              },
            },
            'visualizations': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'title': {'type': 'string'},
                  'type': {'type': 'string'},
                  'url': {'type': 'string'},
                },
              },
            },
            'recommendations': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': ['analysis', 'visualizations'],
        };

        final result = await optimizeSystemPrompt(
          baseSystem: complexSystem,
          samplePrompts: complexPrompts,
          toolSchemas: complexTools,
          outputSchema: complexSchema,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
        expect(result.optimizedSystem, contains('analyzeData'));
        expect(result.optimizedSystem, contains('createVisualization'));
        expect(result.optimizedSystem, contains('analysis'));
        expect(result.optimizedSystem, contains('visualizations'));
        expect(result.optimizedSystem, contains('recommendations'));
      });
    });

    group('Boundary Value Tests', () {
      test('exactly one sample prompt', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a helpful assistant.',
          samplePrompts: ['Single prompt'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('exactly three sample prompts', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a helpful assistant.',
          samplePrompts: ['Prompt 1', 'Prompt 2', 'Prompt 3'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, isNotEmpty);
      });

      test('exactly one tool schema', () async {
        final result = await optimizeSystemPrompt(
          baseSystem: 'You are a single-tool assistant.',
          samplePrompts: ['Use the tool'],
          toolSchemas: [
            {
              'name': 'singleTool',
              'description': 'The only tool available',
              'parameters': {
                'type': 'object',
                'properties': {
                  'input': {'type': 'string'},
                },
                'required': ['input'],
              },
            },
          ],
          outputSchema: null,
          model: testModel,
        );

        expect(result, isA<OptimizedConfig>());
        expect(result.optimizedSystem, contains('singleTool'));
      });
    });
  });
}
