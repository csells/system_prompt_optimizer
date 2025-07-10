import 'dart:convert';

import 'package:json_schema/json_schema.dart';

class SpoFormData {
  String apiKey;
  String model;
  String baseSystem;
  List<String> samplePrompts;
  List<Map<String, dynamic>> toolSchemas;
  String outputSchemaJson;

  SpoFormData({
    this.apiKey = '',
    this.model = 'google:gemini-2.5-flash',
    this.baseSystem = '',
    List<String>? samplePrompts,
    this.toolSchemas = const [],
    this.outputSchemaJson = '',
  }) : samplePrompts = samplePrompts ?? [];

  Map<String, dynamic>? get outputSchema {
    if (outputSchemaJson.trim().isEmpty) return null;
    return json.decode(outputSchemaJson) as Map<String, dynamic>;
  }

  bool get isValid {
    return apiKey.trim().isNotEmpty &&
        model.trim().isNotEmpty &&
        baseSystem.trim().isNotEmpty &&
        samplePrompts.where((p) => p.trim().isNotEmpty).isNotEmpty &&
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
    'samplePrompts': samplePrompts,
    'toolSchemas': toolSchemas,
    'outputSchemaJson': outputSchemaJson,
  };

  factory SpoFormData.fromJson(Map<String, dynamic> json) {
    // Handle backward compatibility
    List<String> prompts = [];
    if (json.containsKey('samplePrompts')) {
      prompts =
          (json['samplePrompts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } else {
      // Legacy format - convert old fields
      final prompt1 = json['samplePrompt1'] ?? '';
      final prompt2 = json['samplePrompt2'] ?? '';
      final prompt3 = json['samplePrompt3'] ?? '';
      prompts = [prompt1, prompt2, prompt3]
          .where((p) => p.toString().trim().isNotEmpty)
          .map((p) => p.toString())
          .toList();
    }

    return SpoFormData(
      apiKey: json['apiKey'] ?? '',
      model: json['model'] ?? 'google:gemini-2.5-flash',
      baseSystem: json['baseSystem'] ?? '',
      samplePrompts: prompts,
      toolSchemas:
          (json['toolSchemas'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      outputSchemaJson: json['outputSchemaJson'] ?? '',
    );
  }
}
