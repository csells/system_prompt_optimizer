import 'package:system_prompt_optimizer/system_prompt_optimizer.dart' as smo;

// Helper class to match the old API for tests
class OptimizedConfig {
  final String optimizedSystem;
  OptimizedConfig(this.optimizedSystem);
}

// Helper function to convert the stream to the old Future<OptimizedConfig> API
Future<OptimizedConfig> optimizeSystemPrompt({
  required String baseSystem,
  required List<String> samplePrompts,
  required List<Map<String, dynamic>> toolSchemas,
  Map<String, dynamic>? outputSchema,
  required String model,
}) async {
  final buffer = StringBuffer();

  await for (final chunk in smo.optimizeSystemPrompt(
    baseSystem: baseSystem,
    samplePrompts: samplePrompts,
    toolSchemas: toolSchemas,
    outputSchema: outputSchema,
    model: model,
  )) {
    buffer.write(chunk);
  }

  return OptimizedConfig(buffer.toString());
}
