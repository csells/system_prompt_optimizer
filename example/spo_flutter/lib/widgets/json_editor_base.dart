import 'dart:convert';

import 'package:flutter/material.dart';

abstract class JsonEditorBase extends StatefulWidget {
  final String value;
  final void Function(String) onChanged;
  final String? label;
  final double height;
  final Widget? labelAction;

  const JsonEditorBase({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.height = 200,
    this.labelAction,
  });
}

abstract class JsonEditorBaseState<T extends JsonEditorBase> extends State<T> {
  late TextEditingController _textController;
  bool _isValid = true;
  String? _formattedJson;
  String? _validationMessage;
  bool _isUpdatingProgrammatically = false;

  // Override this to provide custom validation logic
  ValidationResult validateJson(String text);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value);
    _textController.addListener(_onTextChanged);
    _validateJson(widget.value);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _isUpdatingProgrammatically = true;
      if (_textController.text != widget.value) {
        _textController.text = widget.value;
        _validateJson(widget.value);
      }
      // Schedule the flag reset after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _isUpdatingProgrammatically = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isUpdatingProgrammatically) return;
    
    final text = _textController.text;
    widget.onChanged(text);
    _validateJson(text);
  }

  void _validateJson(String text) {
    if (!mounted) return;

    String? formatted;
    bool isValid = true;
    String? message;

    if (text.trim().isNotEmpty) {
      // First check if it's valid JSON
      try {
        final decoded = json.decode(text);
        formatted = const JsonEncoder.withIndent('  ').convert(decoded);
        
        // Then do custom validation
        final result = validateJson(text);
        isValid = result.isValid;
        message = result.message;
      } catch (e) {
        isValid = false;
        message = 'Invalid JSON';
      }
    }

    if (_isValid != isValid || 
        _formattedJson != formatted ||
        _validationMessage != message) {
      setState(() {
        _isValid = isValid;
        _formattedJson = formatted;
        _validationMessage = message;
      });
    }
  }

  void _formatJson() {
    if (_formattedJson != null) {
      _textController.text = _formattedJson!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              // On very narrow screens, wrap the content
              if (constraints.maxWidth < 500) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.label!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        if (!_isValid && _validationMessage != null)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _validationMessage!,
                                style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        if (_isValid && _textController.text.trim().isNotEmpty)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _validationMessage ?? 'Valid',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if ((_isValid && _formattedJson != null) || widget.labelAction != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isValid && _formattedJson != null)
                              TextButton(onPressed: _formatJson, child: const Text('Format')),
                            if (widget.labelAction != null) widget.labelAction!,
                          ],
                        ),
                      ),
                  ],
                );
              }
              
              // On wider screens, keep everything in one row
              return Row(
                children: [
                  Text(
                    widget.label!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  if (!_isValid && _validationMessage != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _validationMessage!,
                          style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (_isValid && _textController.text.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _validationMessage ?? 'Valid',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (_isValid && _formattedJson != null)
                    TextButton(onPressed: _formatJson, child: const Text('Format')),
                  if (widget.labelAction != null) widget.labelAction!,
                ],
              );
            }
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isValid ? Colors.grey : Colors.red,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              color: Colors.grey.shade50,
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: 'Enter JSON here...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ValidationResult {
  final bool isValid;
  final String? message;

  const ValidationResult({required this.isValid, this.message});
}