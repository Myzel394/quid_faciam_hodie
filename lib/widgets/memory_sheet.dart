import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/managers/file_manager.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/modal_sheet.dart';

class MemorySheet extends StatefulWidget {
  final Memory memory;
  final VoidCallback onMemoryDeleted;

  const MemorySheet({
    Key? key,
    required this.memory,
    required this.onMemoryDeleted,
  }) : super(key: key);

  @override
  State<MemorySheet> createState() => _MemorySheetState();
}

class _MemorySheetState extends State<MemorySheet> with Loadable {
  Future<void> deleteFile() async {
    await FileManager.deleteFile(widget.memory.location);
    widget.onMemoryDeleted();
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
            leading: Icon(Icons.delete_forever_sharp),
            title: Text('Delete Memory'),
            onTap: isLoading
                ? null
                : () async {
                    await callWithLoading(deleteFile);

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
            trailing: isLoading ? const CircularProgressIndicator() : null,
          ),
        ],
      ),
    );
  }
}
