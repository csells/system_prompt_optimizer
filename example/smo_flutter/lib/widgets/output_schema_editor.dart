import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/smo_provider.dart';
import 'output_schema_json_editor.dart';

class OutputSchemaEditor extends StatelessWidget {
  const OutputSchemaEditor({super.key});

  void _confirmDelete(BuildContext context, SmoProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Output Schema'),
          content: const Text('Are you sure you want to remove the output schema?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.updateOutputSchema('');
                Navigator.of(context).pop();
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  static const String _sampleSchema = '''{
  "type": "object",
  "properties": {
    "temperature": {
      "type": "number",
      "description": "Temperature in Celsius"
    },
    "conditions": {
      "type": "string",
      "description": "Weather conditions (e.g., sunny, cloudy, rainy)"
    }
  },
  "required": ["temperature", "conditions"]
}''';

  @override
  Widget build(BuildContext context) {
    return Consumer<SmoProvider>(
      builder: (context, provider, child) {
        final hasSchema = provider.formData.outputSchemaJson.trim().isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Output Schema (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (!hasSchema)
                  ElevatedButton.icon(
                    onPressed: () => provider.updateOutputSchema(_sampleSchema),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Schema'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasSchema)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No output schema defined. Add one to enforce structured responses.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OutputSchemaJsonEditor(
                  label: 'Output Schema',
                  value: provider.formData.outputSchemaJson,
                  onChanged: provider.updateOutputSchema,
                  height: 300,
                  labelAction: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, provider),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
