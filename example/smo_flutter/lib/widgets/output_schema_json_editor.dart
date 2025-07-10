import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_schema/json_schema.dart';
import 'json_editor_base.dart';

class OutputSchemaJsonEditor extends JsonEditorBase {
  const OutputSchemaJsonEditor({
    super.key,
    required super.value,
    required super.onChanged,
    super.label,
    super.height,
    super.labelAction,
  });

  @override
  State<OutputSchemaJsonEditor> createState() => _OutputSchemaJsonEditorState();
}

class _OutputSchemaJsonEditorState extends JsonEditorBaseState<OutputSchemaJsonEditor> {
  @override
  ValidationResult validateJson(String text) {
    if (text.trim().isEmpty) {
      return const ValidationResult(isValid: true);
    }

    try {
      final decoded = json.decode(text);
      
      // Validate that the entire content is a valid JSON Schema
      try {
        JsonSchema.create(decoded);
        return const ValidationResult(
          isValid: true,
          message: 'Valid JSON Schema',
        );
      } catch (e) {
        return const ValidationResult(
          isValid: false,
          message: 'Invalid JSON Schema',
        );
      }
    } catch (e) {
      return const ValidationResult(
        isValid: false,
        message: 'Invalid JSON',
      );
    }
  }
}