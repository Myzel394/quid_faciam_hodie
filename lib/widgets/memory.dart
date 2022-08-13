import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/enums.dart';
import 'package:share_location/managers/file_manager.dart';
import 'package:share_location/utils/auth_required.dart';
import 'package:share_location/widgets/raw_memory_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum MemoryFetchStatus {
  preparing,
  loadingMetadata,
  downloading,
  error,
  done,
}

class Memory extends StatefulWidget {
  final String location;
  final DateTime creationDate;

  const Memory({
    Key? key,
    required this.location,
    required this.creationDate,
  }) : super(key: key);

  @override
  State<Memory> createState() => _MemoryState();
}

class _MemoryState extends AuthRequiredState<Memory> {
  late final User _user;
  MemoryFetchStatus status = MemoryFetchStatus.preparing;
  Uint8List? data;
  MemoryType? type;

  @override
  void initState() {
    super.initState();

    loadMemoryFile();
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;

    if (user != null) {
      _user = user;
    }
  }

  Future<void> loadMemoryFile() async {
    final filename = widget.location.split('/').last;

    setState(() {
      status = MemoryFetchStatus.loadingMetadata;
    });

    final response = await supabase
        .from('memories')
        .select()
        .eq('location', '${_user.id}/$filename')
        .limit(1)
        .single()
        .execute();

    if (response.data == null) {
      setState(() {
        status = MemoryFetchStatus.error;
      });
      return;
    }

    setState(() {
      status = MemoryFetchStatus.downloading;
    });

    final memory = response.data;
    final location = memory['location'];
    final memoryType =
        location.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;

    try {
      final fileData = await FileManager.downloadFile('memories', location);

      setState(() {
        status = MemoryFetchStatus.done;
        data = fileData;
        type = memoryType;
      });
    } catch (error) {
      setState(() {
        status = MemoryFetchStatus.error;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == MemoryFetchStatus.error) {
      return const Center(
        child: Text('Memory could not be loaded.'),
      );
    }

    if (status == MemoryFetchStatus.done) {
      return RawMemoryDisplay(
        data: data!,
        type: type!,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(height: SMALL_SPACE),
        () {
          switch (status) {
            // ADD dot loading text
            case MemoryFetchStatus.preparing:
              return const Text('Preparing to download memory');
            case MemoryFetchStatus.loadingMetadata:
              return const Text('Loading memory metadata');
            case MemoryFetchStatus.downloading:
              return const Text('Downloading memory');
            default:
              return const SizedBox();
          }
        }(),
      ],
    );
  }
}
