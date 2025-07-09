import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/smo_provider.dart';

class SamplePromptsEditor extends StatelessWidget {
  const SamplePromptsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SmoProvider>(
      builder: (context, provider, child) {
        final prompts = provider.formData.samplePrompts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sample Prompts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => provider.addSamplePrompt(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Prompt'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (prompts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No sample prompts yet. Add at least one sample prompt.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ...prompts.asMap().entries.map((entry) {
              final index = entry.key;
              final prompt = entry.value;
              return _SamplePromptItem(
                index: index,
                prompt: prompt,
                onUpdate: (newPrompt) =>
                    provider.updateSamplePrompt(index, newPrompt),
                onRemove: () => provider.removeSamplePrompt(index),
              );
            }),
          ],
        );
      },
    );
  }
}

class _SamplePromptItem extends StatefulWidget {
  final int index;
  final String prompt;
  final Function(String) onUpdate;
  final VoidCallback onRemove;

  const _SamplePromptItem({
    required this.index,
    required this.prompt,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_SamplePromptItem> createState() => _SamplePromptItemState();
}

class _SamplePromptItemState extends State<_SamplePromptItem> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.prompt);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(_SamplePromptItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prompt != widget.prompt && _controller.text != widget.prompt) {
      _controller.text = widget.prompt;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onUpdate(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Sample Prompt ${widget.index + 1}',
                border: const OutlineInputBorder(),
                hintText: 'Enter a sample prompt...',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}