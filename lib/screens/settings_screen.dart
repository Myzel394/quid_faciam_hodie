import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/enum_mapping/resolution_preset/texts.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen.dart';
import 'package:quid_faciam_hodie/utils/auth_required.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

const storage = FlutterSecureStorage();

class SettingsScreen extends StatefulWidget {
  static const ID = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends AuthRequiredState<SettingsScreen>
    with Loadable {
  User? user;

  @override
  void initState() {
    super.initState();

    final settings = GlobalValuesManager.settings!;

    // Update UI when settings change
    settings.addListener(() {
      setState(() {});
    });
  }

  @override
  void onAuthenticated(Session session) {
    if (session.user != null) {
      setState(() {
        user = session.user;
      });
    }
  }

  Future<void> deleteUser() async {
    return;

    final localizations = AppLocalizations.of(context)!;

    final response = await supabase
        .from('auth.users')
        .delete()
        .match({'id': user!.id}).execute();

    if (response.error != null) {
      context.showLongErrorSnackBar(message: localizations.generalError);
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      WelcomeScreen.ID,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = GlobalValuesManager.settings!;
    final localizations = AppLocalizations.of(context)!;
    final resolutionTextMapping = getResolutionTextMapping(context);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(localizations.settingsScreenTitle),
      ),
      body: (user == null || isLoading)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  PlatformCircularProgressIndicator(),
                  const SizedBox(height: MEDIUM_SPACE),
                  Text(localizations.settingsScreenLoading),
                ],
              ),
            )
          : Padding(
              padding:
                  EdgeInsets.only(top: isCupertino(context) ? LARGE_SPACE : 0),
              child: SettingsList(
                sections: [
                  SettingsSection(
                    title:
                        Text(localizations.settingsScreenAccountSectionTitle),
                    tiles: <SettingsTile>[
                      SettingsTile(
                        leading: Icon(context.platformIcons.mail),
                        title: Text(user!.email!),
                      ),
                      SettingsTile(
                        leading: Icon(context.platformIcons.time),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('d. MMMM y,  HH:mm:ss')
                                  .format(DateTime.parse(user!.createdAt)),
                            ),
                            const SizedBox(height: SMALL_SPACE),
                            Text(
                              localizations
                                  .settingsScreenAccountSectionCreationDateLabel,
                              style: platformThemeData(
                                context,
                                material: (data) => data.textTheme.bodySmall,
                                cupertino: (data) =>
                                    data.textTheme.tabLabelTextStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SettingsTile(
                        leading: const Icon(Icons.logout_rounded),
                        title: Text(localizations
                            .settingsScreenAccountSectionLogoutLabel),
                        onPressed: (_) async {
                          await callWithLoading(supabase.auth.signOut);

                          if (!mounted) {
                            return;
                          }

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            WelcomeScreen.ID,
                            (route) => false,
                          );
                        },
                      )
                    ],
                  ),
                  SettingsSection(
                    title: Text(
                      localizations.settingsScreenGeneralSectionTitle,
                    ),
                    tiles: <SettingsTile>[
                      SettingsTile(
                        leading: Text(
                          localizations
                              .settingsScreenGeneralSectionQualityLabel,
                        ),
                        title: DropdownButtonFormField<ResolutionPreset>(
                          value: settings.resolution,
                          onChanged: (value) async {
                            if (value == null) {
                              return;
                            }

                            settings.setResolution(value);
                          },
                          items: ResolutionPreset.values
                              .map((value) =>
                                  DropdownMenuItem<ResolutionPreset>(
                                    value: value,
                                    child: Text(resolutionTextMapping[value]!),
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  ),
                  SettingsSection(
                    title: Text(localizations.settingsScreenDangerSectionTitle),
                    tiles: <SettingsTile>[
                      SettingsTile(
                        leading: Icon(context.platformIcons.delete),
                        title: Text(localizations
                            .settingsScreenDangerSectionDeleteAccountLabel),
                        onPressed: (_) => showPlatformDialog(
                          context: context,
                          builder: (platformContext) => PlatformAlertDialog(
                            title: Text(
                              localizations
                                  .settingsScreenDangerSectionDeleteAccountLabel,
                            ),
                            content: Text(
                              localizations
                                  .settingsScreenDeleteAccountDescription,
                              style: getBodyTextTextStyle(platformContext),
                            ),
                            actions: [
                              PlatformDialogAction(
                                child: Text(
                                  localizations.generalCancelButtonLabel,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              PlatformDialogAction(
                                child: Text(
                                  localizations
                                      .settingsScreenDeleteAccountConfirmLabel,
                                ),
                                onPressed: () => callWithLoading(deleteUser),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
