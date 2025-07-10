import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:system_prompt_optimizer/system_prompt_optimizer.dart';

import '../models/spo_form_data.dart';

class SpoProvider extends ChangeNotifier {
  static const _boxName = 'spo_secure_box';
  static const _storageKey = 'spo_form_data';

  late Box _box;

  SpoFormData _formData = SpoFormData();
  String _optimizedOutput = '';
  bool _isOptimizing = false;
  String? _error;
  bool _isStreamComplete = false;
  bool _isInitialized = false;

  SpoFormData get formData => _formData;
  String get optimizedOutput => _optimizedOutput;
  bool get isOptimizing => _isOptimizing;
  String? get error => _error;
  bool get isStreamComplete => _isStreamComplete;
  bool get isInitialized => _isInitialized;

  SpoProvider() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    // On web, encryption is not supported by Hive, so use regular box On
    // mobile/desktop, use encryption for better security
    if (kIsWeb) {
      _box = await Hive.openBox(_boxName);
    } else {
      const encryptionKey = 'SPOSecureKey32CharactersLong!!!!'; // 32 bytes
      final encryptionKeyBytes = utf8.encode(encryptionKey);
      _box = await Hive.openBox(
        _boxName,
        encryptionCipher: HiveAesCipher(encryptionKeyBytes),
      );
    }

    await _loadSavedData();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSavedData() async {
    final jsonString = _box.get(_storageKey) as String?;
    if (jsonString != null) {
      final decoded = json.decode(jsonString);
      _formData = SpoFormData.fromJson(decoded);
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final jsonData = json.encode(_formData.toJson());
    await _box.put(_storageKey, jsonData);
  }

  void updateApiKey(String value) {
    _formData.apiKey = value;
    notifyListeners();
    _saveData();
  }

  void updateModel(String value) {
    _formData.model = value;
    notifyListeners();
    _saveData();
  }

  void updateBaseSystem(String value) {
    _formData.baseSystem = value;
    notifyListeners();
    _saveData();
  }

  void addSamplePrompt() {
    // Add weather-themed prompt for the first one, empty for others
    final newPrompt = _formData.samplePrompts.isEmpty 
        ? 'lookup the weather in Boston'
        : '';
    _formData.samplePrompts = [..._formData.samplePrompts, newPrompt];
    notifyListeners();
    _saveData();
  }

  void updateSamplePrompt(int index, String value) {
    final prompts = [..._formData.samplePrompts];
    if (index >= 0 && index < prompts.length) {
      prompts[index] = value;
      _formData.samplePrompts = prompts;
      notifyListeners();
      _saveData();
    }
  }

  void removeSamplePrompt(int index) {
    final prompts = [..._formData.samplePrompts];
    if (index >= 0 && index < prompts.length) {
      prompts.removeAt(index);
      _formData.samplePrompts = prompts;
      notifyListeners();
      _saveData();
    }
  }

  void updateOutputSchema(String value) {
    _formData.outputSchemaJson = value;
    notifyListeners();
    _saveData();
  }

  void addToolSchema(Map<String, dynamic> schema) {
    _formData.toolSchemas = [..._formData.toolSchemas, schema];
    notifyListeners();
    _saveData();
  }

  void updateToolSchema(int index, Map<String, dynamic> schema) {
    final schemas = [..._formData.toolSchemas];
    if (index >= 0 && index < schemas.length) {
      schemas[index] = schema;
      _formData.toolSchemas = schemas;
      notifyListeners();
      _saveData();
    }
  }

  void removeToolSchema(int index) {
    final schemas = [..._formData.toolSchemas];
    if (index >= 0 && index < schemas.length) {
      schemas.removeAt(index);
      _formData.toolSchemas = schemas;
      notifyListeners();
      _saveData();
    }
  }

  Future<void> optimize() async {
    if (!_formData.isValid || _isOptimizing) return;

    _isOptimizing = true;
    _optimizedOutput = '';
    _error = null;
    _isStreamComplete = false;
    notifyListeners();

    // This try-catch is necessary - we need to capture errors to show them in
    // the UI
    try {
      final stream = optimizeSystemPrompt(
        model: _formData.model,
        apiKey: _formData.apiKey,
        systemPrompt: _formData.baseSystem,
        samplePrompts: _formData.samplePrompts
            .where((p) => p.trim().isNotEmpty)
            .toList(),
        toolSchemas: _formData.toolSchemas,
        outputSchema: _formData.outputSchema,
      );

      await for (final chunk in stream) {
        _optimizedOutput += chunk;
        notifyListeners();
      }

      _isStreamComplete = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isOptimizing = false;
      notifyListeners();
    }
  }

  void clearOutput() {
    _optimizedOutput = '';
    _error = null;
    _isStreamComplete = false;
    notifyListeners();
  }
}
