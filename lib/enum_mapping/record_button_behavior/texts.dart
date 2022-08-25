import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/enums/record_button_behavior.dart';

Map<RecordButtonBehavior, String> getRecordButtonBehaviorTextMapping(
    final BuildContext context) {
  final localizations = AppLocalizations.of(context)!;

  return {
    RecordButtonBehavior.holdRecording:
        localizations.enumMapping_RecordButtonBehavior_holdRecording,
    RecordButtonBehavior.switchRecording:
        localizations.enumMapping_RecordButtonBehavior_switchRecording,
  };
}
