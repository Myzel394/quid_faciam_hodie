import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/managers/file_manager.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
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

      context.showSuccessSnackBar(
          message: localizations.memorySheetSavedToGallery);
    } catch (error) {
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
        context.showSuccessSnackBar(
            message: localizations.memorySheetMemoryUpdatedToPublic);
      } else {
        context.showSuccessSnackBar(
            message: localizations.memorySheetMemoryUpdatedToPrivate);
      }
    } catch (error) {
      context.showErrorSnackBar(message: localizations.generalError);
    }
  }

  Widget buildLoadingIndicator() {
    final theme = Theme.of(context);

    return SizedBox(
      width: theme.textTheme.titleLarge!.fontSize,
      height: theme.textTheme.titleLarge!.fontSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: theme.textTheme.bodyText1!.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ModalSheet(
      child: Column(
        children: <Widget>[
          Text(
            localizations.memorySheetTitle,
            style: theme.textTheme.headline1,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(localizations.memorySheetDownloadMemory),
            enabled: !getIsLoadingSpecificID('download'),
            onTap: getIsLoadingSpecificID('download')
                ? null
                : () => callWithLoading(downloadFile, 'download'),
            trailing: getIsLoadingSpecificID('download')
                ? buildLoadingIndicator()
                : null,
          ),
          ListTile(
            leading: Icon(widget.memory.isPublic
                ? Icons.public_off_rounded
                : Icons.public_rounded),
            title: Text(
              widget.memory.isPublic
                  ? localizations.memorySheetUpdateMemoryMakePrivate
                  : localizations.memorySheetUpdateMemoryMakePublic,
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
            leading: const Icon(Icons.delete_forever_sharp),
            title: Text(localizations.memorySheetDeleteMemory),
            enabled: !getIsLoadingSpecificID('delete'),
            onTap: getIsLoadingSpecificID('delete')
                ? null
                : () => callWithLoading(deleteFile, 'delete'),
            trailing: getIsLoadingSpecificID('delete')
                ? buildLoadingIndicator()
                : null,
          ),
        ],
      ),
    );
  }
}
