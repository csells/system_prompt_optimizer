import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smo_provider.dart';
import 'tool_schema_json_editor.dart';

class ToolSchemaEditor extends StatelessWidget {
  const ToolSchemaEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SmoProvider>(
      builder: (context, provider, child) {
        final schemas = provider.formData.toolSchemas;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tool Schemas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _addNewTool(context, provider),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tool'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...schemas.asMap().entries.map((entry) {
              final index = entry.key;
              final schema = entry.value;
              return _ToolSchemaItem(
                index: index,
                schema: schema,
                onUpdate: (newSchema) =>
                    provider.updateToolSchema(index, newSchema),
                onRemove: () => provider.removeToolSchema(index),
              );
            }),
          ],
        );
      },
    );
  }

  void _addNewTool(BuildContext context, SmoProvider provider) {
    provider.addToolSchema({
      'name': 'toolName',
      'description': 'Tool description',
      'parameters': {
        'type': 'object',
        'properties': {},
      },
    });
  }
}

class _ToolSchemaItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> schema;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onRemove;

  const _ToolSchemaItem({
    required this.index,
    required this.schema,
    required this.onUpdate,
    required this.onRemove,
  });

  void _updateSchema(String value) {
    if (value.trim().isNotEmpty) {
      // Only update if we have valid JSON - validation is handled by JsonEditorField
      final decoded = json.decode(value) as Map<String, dynamic>;
      onUpdate(decoded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final toolName = schema['name'] ?? 'Unnamed Tool';
    final jsonString = const JsonEncoder.withIndent('  ').convert(schema);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ToolSchemaJsonEditor(
        label: 'Tool ${index + 1}: $toolName',
        value: jsonString,
        onChanged: _updateSchema,
        height: 250,
        labelAction: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}