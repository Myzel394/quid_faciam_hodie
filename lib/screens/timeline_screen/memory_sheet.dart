import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/managers/file_manager.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/modal_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemorySheet extends StatefulWidget {
  final Memory memory;
  final BuildContext sheetContext;

  const MemorySheet({
    Key? key,
    required this.memory,
    required this.sheetContext,
  }) : super(key: key);

  @override
  State<MemorySheet> createState() => _MemorySheetState();
}

final supabase = Supabase.instance.client;

class _MemorySheetState extends State<MemorySheet> with Loadable {
  Future<void> deleteFile() async {
    await FileManager.deleteFile(widget.memory.location);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> downloadFile() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final file = await widget.memory.downloadToFile();

      switch (widget.memory.type) {
        case MemoryType.photo:
          await GallerySaver.saveImage(file.path);
          break;
        case MemoryType.video:
          await GallerySaver.saveVideo(file.path);
          break;
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      if (isMaterial(context))
        context.showSuccessSnackBar(
            message: localizations.memorySheetSavedToGallery);
    } catch (error) {
      if (isMaterial(context))
        context.showErrorSnackBar(message: localizations.generalError);
    }
  }

  Future<void> changeVisibility() async {
    final localizations = AppLocalizations.of(context)!;

    final isNowPublic = !widget.memory.isPublic == true;

    try {
      await supabase.from('memories').update({
        'is_public': !widget.memory.isPublic,
      }).match({
        'id': widget.memory.id,
      }).execute();

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      if (isNowPublic) {
        if (isMaterial(context))
          context.showSuccessSnackBar(
              message: localizations.memorySheetMemoryUpdatedToPublic);
      } else {
        if (isMaterial(context))
          context.showSuccessSnackBar(
              message: localizations.memorySheetMemoryUpdatedToPrivate);
      }
    } catch (error) {
      if (isMaterial(context))
        context.showErrorSnackBar(message: localizations.generalError);
    }
  }

  Widget buildLoadingIndicator() {
    final size = platformThemeData(
      context,
      material: (data) => data.textTheme.titleLarge!.fontSize,
      cupertino: (data) => data.textTheme.textStyle.fontSize,
    );

    return SizedBox.square(
      dimension: size,
      child: PlatformCircularProgressIndicator(
        material: (_, __) => MaterialProgressIndicatorData(
          strokeWidth: 2,
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ModalSheet(
      child: Column(
        children: <Widget>[
          Text(
            localizations.memorySheetTitle,
            style: getTitleTextStyle(context),
          ),
          const SizedBox(height: MEDIUM_SPACE),
          ListTile(
            leading: PlatformWidget(
              cupertino: (_, __) => Icon(
                CupertinoIcons.down_arrow,
                color: getBodyTextColor(context),
              ),
              material: (_, __) => Icon(
                Icons.download,
                color: getBodyTextColor(context),
              ),
            ),
            title: Text(
              localizations.memorySheetDownloadMemory,
              style: getBodyTextTextStyle(context),
            ),
            enabled: !getIsLoadingSpecificID('download'),
            onTap: getIsLoadingSpecificID('download')
                ? null
                : () => callWithLoading(downloadFile, 'download'),
            trailing: getIsLoadingSpecificID('download')
                ? buildLoadingIndicator()
                : null,
          ),
          ListTile(
            leading: Icon(
              widget.memory.isPublic ? Icons.public_off_rounded : Icons.public,
              color: getBodyTextColor(context),
            ),
            title: Text(
              widget.memory.isPublic
                  ? localizations.memorySheetUpdateMemoryMakePrivate
                  : localizations.memorySheetUpdateMemoryMakePublic,
              style: getBodyTextTextStyle(context),
            ),
            enabled: !getIsLoadingSpecificID('public'),
            onTap: getIsLoadingSpecificID('public')
                ? null
                : () => callWithLoading(changeVisibility, 'public'),
            trailing: getIsLoadingSpecificID('public')
                ? buildLoadingIndicator()
                : null,
          ),
          ListTile(
            leading: Icon(
              context.platformIcons.delete,
              color: getBodyTextColor(context),
            ),
            title: Text(
              localizations.memorySheetDeleteMemory,
              style: getBodyTextTextStyle(context),
            ),
            enabled: !getIsLoadingSpecificID('delete'),
            onTap: getIsLoadingSpecificID('delete')
                ? null
                : () => callWithLoading(deleteFile, 'delete'),
            trailing: getIsLoadingSpecificID('delete')
                ? buildLoadingIndicator()
                : null,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          Text(
            localizations.memorySheetCreatedAtDataKey(DateFormat.jms().format(
              widget.memory.creationDate,
            )),
            style: getBodyTextTextStyle(context),
          ),
          const SizedBox(height: SMALL_SPACE),
          Text(
            widget.memory.id,
            textAlign: TextAlign.center,
            style: getBodyTextTextStyle(context),
          )
        ],
      ),
    );
  }
}
