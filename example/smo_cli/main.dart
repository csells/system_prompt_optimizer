import 'dart:io';

import 'package:system_prompt_optimizer/system_prompt_optimizer.dart';

void main() async {
  print('System Message Optimizer Demo\n');
  print('=' * 50);

  // Define test inputs
  final systemPrompt = '''
You are a helpful AI assistant specializing in cooking and recipe recommendations.
You should provide clear, easy-to-follow cooking instructions and suggest recipes
based on available ingredients, dietary restrictions, and user preferences.
''';

  final samplePrompts = [
    'I have chicken, rice, and vegetables. What can I make for dinner?',
    'Can you give me a vegetarian pasta recipe?',
    'How do I make chocolate chip cookies from scratch?',
  ];

  // Define tool schemas for recipe-related operations
  final searchRecipeSchema = {
    'name': 'searchRecipes',
    'description': 'Search for recipes based on ingredients or dish name',
    'parameters': {
      'type': 'object',
      'properties': {
        'query': {'type': 'string', 'description': 'Search query for recipes'},
        'ingredients': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'List of ingredients to include',
        },
        'dietaryRestrictions': {
          'type': 'array',
          'items': {
            'type': 'string',
            'enum': [
              'vegetarian',
              'vegan',
              'gluten-free',
              'dairy-free',
              'nut-free',
            ],
          },
          'description': 'Dietary restrictions to consider',
        },
        'maxCookTime': {
          'type': 'integer',
          'description': 'Maximum cooking time in minutes',
        },
      },
      'required': ['query'],
    },
  };

  final nutritionInfoSchema = {
    'name': 'getNutritionInfo',
    'description': 'Get nutritional information for a recipe or ingredient',
    'parameters': {
      'type': 'object',
      'properties': {
        'item': {'type': 'string', 'description': 'Recipe name or ingredient'},
        'servingSize': {
          'type': 'string',
          'description': 'Serving size (e.g., "1 cup", "100g")',
        },
      },
      'required': ['item'],
    },
  };

  // Define output schema for recipe responses
  final recipeOutputSchema = {
    'type': 'object',
    'properties': {
      'recipeName': {'type': 'string', 'description': 'Name of the recipe'},
      'description': {
        'type': 'string',
        'description': 'Brief description of the dish',
      },
      'prepTime': {
        'type': 'integer',
        'description': 'Preparation time in minutes',
      },
      'cookTime': {'type': 'integer', 'description': 'Cooking time in minutes'},
      'servings': {'type': 'integer', 'description': 'Number of servings'},
      'ingredients': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'item': {'type': 'string'},
            'amount': {'type': 'string'},
            'unit': {'type': 'string'},
          },
          'required': ['item', 'amount'],
        },
      },
      'instructions': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'step': {'type': 'integer'},
            'instruction': {'type': 'string'},
          },
          'required': ['step', 'instruction'],
        },
      },
      'nutritionPerServing': {
        'type': 'object',
        'properties': {
          'calories': {'type': 'integer'},
          'protein': {'type': 'string'},
          'carbs': {'type': 'string'},
          'fat': {'type': 'string'},
        },
      },
    },
    'required': ['recipeName', 'ingredients', 'instructions'],
  };

  print('Input Configuration:');
  print('Base System: ${systemPrompt.trim()}');
  print('\nSample Prompts:');
  for (var i = 0; i < samplePrompts.length; i++) {
    print('  ${i + 1}. ${samplePrompts[i]}');
  }
  print('\nTool Schemas: searchRecipes, getNutritionInfo');
  print('Output Schema: Recipe format with ingredients and instructions');
  print('\n${'-' * 50}\n');

  print('Optimizing system message...\n');

  await optimizeSystemPrompt(
    systemPrompt: systemPrompt,
    samplePrompts: samplePrompts,
    toolSchemas: [searchRecipeSchema, nutritionInfoSchema],
    outputSchema: recipeOutputSchema,
  ).forEach(stdout.write);
  stdout.writeln();

  print('\n\n${'-' * 50}');
  print('OPTIMIZATION COMPLETE');
  print('${'-' * 50}\n');
  exit(0);
}
