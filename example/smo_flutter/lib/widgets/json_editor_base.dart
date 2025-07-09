import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/github.dart';

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
  late CodeLineEditingController _codeController;
  bool _isValid = true;
  String? _formattedJson;
  String? _validationMessage;

  // Use simple TextField on macOS to avoid crash, re_editor on other platforms
  bool get _useMacOSFallback => !kIsWeb && Platform.isMacOS;

  // Override this to provide custom validation logic
  ValidationResult validateJson(String text);

  @override
  void initState() {
    super.initState();

    if (_useMacOSFallback) {
      _textController = TextEditingController(text: widget.value);
      _textController.addListener(_onTextChanged);
    } else {
      _codeController = CodeLineEditingController.fromText(widget.value);
      // Add listener after first frame to avoid build-time setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _codeController.addListener(_onTextChanged);
        }
      });
    }

    _validateJson(widget.value);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (_useMacOSFallback) {
        if (_textController.text != widget.value) {
          _textController.text = widget.value;
          _validateJson(widget.value);
        }
      } else {
        if (_codeController.text != widget.value) {
          _codeController.text = widget.value;
          _validateJson(widget.value);
        }
      }
    }
  }

  @override
  void dispose() {
    if (_useMacOSFallback) {
      _textController.removeListener(_onTextChanged);
      _textController.dispose();
    } else {
      _codeController.removeListener(_onTextChanged);
      _codeController.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _useMacOSFallback
        ? _textController.text
        : _codeController.text;
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
      if (_useMacOSFallback) {
        _textController.text = _formattedJson!;
      } else {
        _codeController.text = _formattedJson!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              if (!_isValid && _validationMessage != null)
                Container(
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
                  ),
                ),
              if (_isValid && 
                  (_useMacOSFallback
                      ? _textController.text.trim().isNotEmpty
                      : _codeController.text.trim().isNotEmpty))
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
            child: _useMacOSFallback
                ? Container(
                    color: Colors.grey.shade50,
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: 'Monaco',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                        hintText: 'Enter JSON here...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: 'Monaco',
                        ),
                      ),
                    ),
                  )
                : CodeEditor(
                    controller: _codeController,
                    style: CodeEditorStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      codeTheme: CodeHighlightTheme(
                        languages: {
                          'json': CodeHighlightThemeMode(mode: langJson),
                        },
                        theme: githubTheme,
                      ),
                    ),
                    wordWrap: false,
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