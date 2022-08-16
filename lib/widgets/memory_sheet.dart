import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/enums.dart';
import 'package:share_location/extensions/snackbar.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/managers/file_manager.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/modal_sheet.dart';
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
    try {
      final file =
          await FileManager.downloadFile('memories', widget.memory.location);

      if (!mounted) {
        return;
      }

      switch (widget.memory.type) {
        case MemoryType.photo:
          await GallerySaver.saveImage(file.path);
          break;
        case MemoryType.video:
          await GallerySaver.saveVideo(file.path);
          break;
      }

      Navigator.pop(context);

      context.showSuccessSnackBar(message: 'File saved to Gallery!');
    } catch (error) {
      context.showErrorSnackBar(message: 'There was an error.');
    }
  }

  Future<void> changeVisibility() async {
    final isNowPublic = !widget.memory.isPublic == true;

    try {
      await supabase.from('memories').update({
        'is_public': !widget.memory.isPublic,
      }).match({
        'id': widget.memory.id,
      }).execute();

      Navigator.pop(context);

      if (isNowPublic) {
        context.showSuccessSnackBar(message: 'Your Memory is public now!');
      } else {
        context.showSuccessSnackBar(message: 'Your Memory is private now.');
      }
    } catch (error) {
      context.showErrorSnackBar(message: 'There was an error.');
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
    final theme = Theme.of(context);

    return ModalSheet(
      child: Column(
        children: <Widget>[
          Text(
            'Edit Memory',
            style: theme.textTheme.headline1,
          ),
          const SizedBox(height: MEDIUM_SPACE),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download to Gallery'),
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
            title:
                Text(widget.memory.isPublic ? 'Make private' : 'Make public'),
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
            title: const Text('Delete Memory'),
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
