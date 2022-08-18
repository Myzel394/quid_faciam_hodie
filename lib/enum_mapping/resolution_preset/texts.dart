import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Map<ResolutionPreset, String> getResolutionTextMapping(
    final BuildContext context) {
  final localizations = AppLocalizations.of(context)!;

  return {
    ResolutionPreset.low: localizations.enumMapping_ResolutionPreset_low,
    ResolutionPreset.medium: localizations.enumMapping_ResolutionPreset_medium,
    ResolutionPreset.high: localizations.enumMapping_ResolutionPreset_high,
    ResolutionPreset.veryHigh:
        localizations.enumMapping_ResolutionPreset_veryHigh,
    ResolutionPreset.ultraHigh:
        localizations.enumMapping_ResolutionPreset_ultraHigh,
    ResolutionPreset.max: localizations.enumMapping_ResolutionPreset_max,
  };
}
