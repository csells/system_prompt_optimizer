import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/spo_provider.dart';
import '../widgets/output_schema_editor.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/sample_prompts_editor.dart';
import '../widgets/tool_schema_editor.dart';

class SpoScreen extends StatelessWidget {
  const SpoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Prompt Optimizer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ResponsiveLayout(
        formPanel: _FormPanel(),
        outputPanel: _OutputPanel(),
      ),
    );
  }
}

class _FormPanel extends StatefulWidget {
  @override
  State<_FormPanel> createState() => _FormPanelState();
}

class _FormPanelState extends State<_FormPanel> {
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _baseSystemController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SpoProvider>();

    // Initialize controllers with current values
    _apiKeyController = TextEditingController(text: provider.formData.apiKey);
    _modelController = TextEditingController(text: provider.formData.model);
    _baseSystemController = TextEditingController(
      text: provider.formData.baseSystem,
    );

    // Listen for changes from provider (when data is loaded from storage)
    provider.addListener(_updateControllers);

    // Update controllers if data is already loaded
    if (provider.isInitialized) {
      _updateControllers();
    }
  }

  void _updateControllers() {
    final provider = context.read<SpoProvider>();
    if (_apiKeyController.text != provider.formData.apiKey) {
      _apiKeyController.text = provider.formData.apiKey;
    }
    if (_modelController.text != provider.formData.model) {
      _modelController.text = provider.formData.model;
    }
    if (_baseSystemController.text != provider.formData.baseSystem) {
      _baseSystemController.text = provider.formData.baseSystem;
    }
  }

  @override
  void dispose() {
    context.read<SpoProvider>().removeListener(_updateControllers);
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseSystemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpoProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Model Section
              _buildModelSection(context, provider),
              const SizedBox(height: 24),

              // API Key Section
              _buildApiKeySection(context, provider),
              const SizedBox(height: 24),

              // Base System Section
              _buildBaseSystemSection(context, provider),
              const SizedBox(height: 24),

              // Sample Prompts Section
              _buildSamplePromptsSection(context, provider),
              const SizedBox(height: 24),

              // Tool Schemas Section
              const ToolSchemaEditor(),
              const SizedBox(height: 24),

              // Output Schema Section
              const OutputSchemaEditor(),
              const SizedBox(height: 24),

              // Optimize Button
              ElevatedButton(
                onPressed: provider.formData.isValid && !provider.isOptimizing
                    ? () => provider.optimize()
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: provider.isOptimizing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Optimize System Message'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApiKeySection(BuildContext context, SpoProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('API Key', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Get Gemini API Key'),
              onPressed: () async {
                final url = Uri.parse('https://aistudio.google.com/app/apikey');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKeyController,
          onChanged: provider.updateApiKey,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter your API key',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildModelSection(BuildContext context, SpoProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Model', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _modelController,
          onChanged: provider.updateModel,
          decoration: const InputDecoration(
            hintText: 'e.g., google:gemini-2.5-flash',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildBaseSystemSection(BuildContext context, SpoProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Base System Message',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _baseSystemController,
          onChanged: provider.updateBaseSystem,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your base system message...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSamplePromptsSection(
    BuildContext context,
    SpoProvider provider,
  ) {
    return const SamplePromptsEditor();
  }

}

class _OutputPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpoProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error occurred:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.clearOutput,
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        }

        if (provider.optimizedOutput.isEmpty && !provider.isOptimizing) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Optimized system message will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.isStreamComplete)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy to clipboard',
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: provider.optimizedOutput),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    provider.optimizedOutput,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            if (provider.isOptimizing)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}
