import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY')
  static const String openAiApiKey = _Env.openAiApiKey;

  @EnviedField(varName: 'FAL_AI_API_KEY')
  static const String falAiApiKey = _Env.falAiApiKey;
}
