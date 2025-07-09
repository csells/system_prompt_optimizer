import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:system_prompt_optimizer/system_prompt_optimizer.dart';

import '../models/smo_form_data.dart';

class SmoProvider extends ChangeNotifier {
  static const _boxName = 'smo_secure_box';
  static const _storageKey = 'smo_form_data';

  late Box _box;

  SmoFormData _formData = SmoFormData();
  String _optimizedOutput = '';
  bool _isOptimizing = false;
  String? _error;
  bool _isStreamComplete = false;
  bool _isInitialized = false;

  SmoFormData get formData => _formData;
  String get optimizedOutput => _optimizedOutput;
  bool get isOptimizing => _isOptimizing;
  String? get error => _error;
  bool get isStreamComplete => _isStreamComplete;
  bool get isInitialized => _isInitialized;

  SmoProvider() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    // On web, encryption is not supported by Hive, so use regular box
    // On mobile/desktop, use encryption for better security
    if (kIsWeb) {
      _box = await Hive.openBox(_boxName);
    } else {
      const encryptionKey = 'SMOSecureKey32CharactersLong!!!!'; // 32 bytes
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
      _formData = SmoFormData.fromJson(decoded);
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

  void updateSamplePrompt(int index, String value) {
    switch (index) {
      case 0:
        _formData.samplePrompt1 = value;
        break;
      case 1:
        _formData.samplePrompt2 = value;
        break;
      case 2:
        _formData.samplePrompt3 = value;
        break;
    }
    notifyListeners();
    _saveData();
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

    // This try-catch is necessary - we need to capture errors to show them in the UI
    try {
      // The dartantic_ai package will need the API key to be set
      // For now, we'll include it in the model string format
      // In a production app, this would be handled more securely
      final modelWithKey = '${_formData.model}?apiKey=${_formData.apiKey}';

      final stream = optimizeSystemPrompt(
        baseSystem: _formData.baseSystem,
        samplePrompts: _formData.samplePrompts,
        toolSchemas: _formData.toolSchemas,
        outputSchema: _formData.outputSchema,
        model: modelWithKey,
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
