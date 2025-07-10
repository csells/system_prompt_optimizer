import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_schema/json_schema.dart';
import 'json_editor_base.dart';

class ToolSchemaJsonEditor extends JsonEditorBase {
  const ToolSchemaJsonEditor({
    super.key,
    required super.value,
    required super.onChanged,
    super.label,
    super.height,
    super.labelAction,
  });

  @override
  State<ToolSchemaJsonEditor> createState() => _ToolSchemaJsonEditorState();
}

class _ToolSchemaJsonEditorState extends JsonEditorBaseState<ToolSchemaJsonEditor> {
  @override
  ValidationResult validateJson(String text) {
    if (text.trim().isEmpty) {
      return const ValidationResult(isValid: true);
    }

    try {
      final decoded = json.decode(text);
      
      // Check if it's a valid tool schema structure
      if (decoded is! Map<String, dynamic>) {
        return const ValidationResult(
          isValid: false,
          message: 'Invalid Tool Schema',
        );
      }

      // Tool schema should have name, description, and parameters
      if (!decoded.containsKey('name') || 
          !decoded.containsKey('description') ||
          !decoded.containsKey('parameters')) {
        return const ValidationResult(
          isValid: false,
          message: 'Missing required fields',
        );
      }

      // Validate that parameters is a valid JSON Schema
      final parameters = decoded['parameters'];
      if (parameters != null) {
        try {
          JsonSchema.create(parameters);
        } catch (e) {
          return const ValidationResult(
            isValid: false,
            message: 'Invalid parameters schema',
          );
        }
      }

      return const ValidationResult(
        isValid: true,
        message: 'Valid Tool Schema',
      );
    } catch (e) {
      return const ValidationResult(
        isValid: false,
        message: 'Invalid JSON',
      );
    }
  }
}