import 'package:system_prompt_optimizer/system_prompt_optimizer.dart';
import 'package:test/test.dart';

void main() {
  group('SMO Edge Cases and Boundary Tests', () {
    const testModel = 'openai:gpt-4o-mini';

    group('Empty and Minimal Inputs', () {
      test('handles empty baseSystem', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: '',
          samplePrompts: ['Do something'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });

      test('handles whitespace-only baseSystem', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: '   \n\t  ',
          samplePrompts: ['Help with task'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });

      test('handles single-word baseSystem', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'Assistant',
          samplePrompts: ['Help'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result.toLowerCase(), contains('assistant'));
      });

      test('handles empty sample prompts list', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a helpful assistant.',
          samplePrompts: [],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });

      test('handles single empty sample prompt', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a helpful assistant.',
          samplePrompts: [''],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });

      test('handles whitespace-only sample prompts', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a helpful assistant.',
          samplePrompts: ['   ', '\n\t', '  \n  '],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
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
          systemPrompt: 'You are a system monitoring assistant.',
          samplePrompts: ['Check system status'],
          toolSchemas: simpleTools,
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, contains('ping'));
        expect(result, contains('status'));
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
          systemPrompt: 'You return structured primitive data.',
          samplePrompts: ['Give me some data'],
          toolSchemas: [],
          outputSchema: primitiveSchema,
          model: testModel,
        ).join();

        expect(result, contains('string'));
        expect(result, contains('number'));
        expect(result, contains('boolean'));
      });

      test('handles empty output schema', () async {
        final emptySchema = {'type': 'object', 'properties': {}};

        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a minimal assistant.',
          samplePrompts: ['Help'],
          toolSchemas: [],
          outputSchema: emptySchema,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });
    });

    group('All Combinations', () {
      test('absolutely minimal valid input', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'A',
          samplePrompts: ['B'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
        expect(result.length, greaterThan(2));
      });

      test('everything empty except required fields', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: '',
          samplePrompts: [],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });

      test('tools but no output schema', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a tool-using assistant.',
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
        ).join();

        expect(result, contains('search'));
        expect(result, contains('query'));
      });

      test('output schema but no tools', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You return structured data.',
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
        ).join();

        expect(result, contains('result'));
        expect(result, contains('confidence'));
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
          systemPrompt: complexSystem,
          samplePrompts: complexPrompts,
          toolSchemas: complexTools,
          outputSchema: complexSchema,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
        expect(result, contains('analyzeData'));
        expect(result, contains('createVisualization'));
        expect(result, contains('analysis'));
        expect(result, contains('visualizations'));
        expect(result, contains('recommendations'));
      });
    });

    group('Boundary Value Tests', () {
      test('exactly one sample prompt', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a helpful assistant.',
          samplePrompts: ['Single prompt'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });

      test('exactly three sample prompts', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a helpful assistant.',
          samplePrompts: ['Prompt 1', 'Prompt 2', 'Prompt 3'],
          toolSchemas: [],
          outputSchema: null,
          model: testModel,
        ).join();

        expect(result, isNotEmpty);
      });

      test('exactly one tool schema', () async {
        final result = await optimizeSystemPrompt(
          systemPrompt: 'You are a single-tool assistant.',
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
        ).join();

        expect(result, contains('singleTool'));
      });
    });
  });
}
