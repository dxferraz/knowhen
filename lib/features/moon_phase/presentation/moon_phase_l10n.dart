import 'package:knowhen/core/functions/get_moon_phase.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

/// Os textos de uma fase da Lua no idioma do app.
extension MoonPhaseL10n on AppLocalizations {
  String moonPhaseName(MoonPhaseType type) => switch (type) {
        MoonPhaseType.newMoon => moonPhaseNewMoonName,
        MoonPhaseType.waxingCrescent => moonPhaseWaxingCrescentName,
        MoonPhaseType.firstQuarter => moonPhaseFirstQuarterName,
        MoonPhaseType.waxingGibbous => moonPhaseWaxingGibbousName,
        MoonPhaseType.fullMoon => moonPhaseFullMoonName,
        MoonPhaseType.waningGibbous => moonPhaseWaningGibbousName,
        MoonPhaseType.lastQuarter => moonPhaseLastQuarterName,
        MoonPhaseType.waningCrescent => moonPhaseWaningCrescentName,
      };

  String moonPhaseDescription(MoonPhaseType type) => switch (type) {
        MoonPhaseType.newMoon => moonPhaseNewMoonDescription,
        MoonPhaseType.waxingCrescent => moonPhaseWaxingCrescentDescription,
        MoonPhaseType.firstQuarter => moonPhaseFirstQuarterDescription,
        MoonPhaseType.waxingGibbous => moonPhaseWaxingGibbousDescription,
        MoonPhaseType.fullMoon => moonPhaseFullMoonDescription,
        MoonPhaseType.waningGibbous => moonPhaseWaningGibbousDescription,
        MoonPhaseType.lastQuarter => moonPhaseLastQuarterDescription,
        MoonPhaseType.waningCrescent => moonPhaseWaningCrescentDescription,
      };

  String moonPhaseInfluence(MoonPhaseType type) => switch (type) {
        MoonPhaseType.newMoon => moonPhaseNewMoonInfluence,
        MoonPhaseType.waxingCrescent => moonPhaseWaxingCrescentInfluence,
        MoonPhaseType.firstQuarter => moonPhaseFirstQuarterInfluence,
        MoonPhaseType.waxingGibbous => moonPhaseWaxingGibbousInfluence,
        MoonPhaseType.fullMoon => moonPhaseFullMoonInfluence,
        MoonPhaseType.waningGibbous => moonPhaseWaningGibbousInfluence,
        MoonPhaseType.lastQuarter => moonPhaseLastQuarterInfluence,
        MoonPhaseType.waningCrescent => moonPhaseWaningCrescentInfluence,
      };
}
