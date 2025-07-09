import 'dart:convert';
import 'package:json_schema/json_schema.dart';

class SmoFormData {
  String apiKey;
  String model;
  String baseSystem;
  String samplePrompt1;
  String samplePrompt2;
  String samplePrompt3;
  List<Map<String, dynamic>> toolSchemas;
  String outputSchemaJson;

  SmoFormData({
    this.apiKey = '',
    this.model = 'google:gemini-2.5-flash',
    this.baseSystem = '',
    this.samplePrompt1 = '',
    this.samplePrompt2 = '',
    this.samplePrompt3 = '',
    this.toolSchemas = const [],
    this.outputSchemaJson = '',
  });

  List<String> get samplePrompts {
    return [samplePrompt1, samplePrompt2, samplePrompt3]
        .where((prompt) => prompt.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic>? get outputSchema {
    if (outputSchemaJson.trim().isEmpty) return null;
    return json.decode(outputSchemaJson) as Map<String, dynamic>;
  }

  bool get isValid {
    return apiKey.trim().isNotEmpty &&
        model.trim().isNotEmpty &&
        baseSystem.trim().isNotEmpty &&
        samplePrompts.isNotEmpty &&
        isOutputSchemaValid;
  }

  bool get isOutputSchemaValid {
    if (outputSchemaJson.trim().isEmpty) return true;
    // This is necessary exception handling for validation
    try {
      final decoded = json.decode(outputSchemaJson);
      if (decoded is Map<String, dynamic>) {
        JsonSchema.create(decoded);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'model': model,
        'baseSystem': baseSystem,
        'samplePrompt1': samplePrompt1,
        'samplePrompt2': samplePrompt2,
        'samplePrompt3': samplePrompt3,
        'toolSchemas': toolSchemas,
        'outputSchemaJson': outputSchemaJson,
      };

  factory SmoFormData.fromJson(Map<String, dynamic> json) {
    return SmoFormData(
      apiKey: json['apiKey'] ?? '',
      model: json['model'] ?? 'google:gemini-2.5-flash',
      baseSystem: json['baseSystem'] ?? '',
      samplePrompt1: json['samplePrompt1'] ?? '',
      samplePrompt2: json['samplePrompt2'] ?? '',
      samplePrompt3: json['samplePrompt3'] ?? '',
      toolSchemas: (json['toolSchemas'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      outputSchemaJson: json['outputSchemaJson'] ?? '',
    );
  }
}