import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/models/timeline.dart';
import 'package:quid_faciam_hodie/widgets/raw_memory_display.dart';
import 'package:video_player/video_player.dart';

enum MemoryFetchStatus {
  downloading,
  error,
  done,
}

class MemoryView extends StatefulWidget {
  final Memory memory;
  final bool loopVideo;
  final void Function(VideoPlayerController)? onVideoControllerInitialized;
  final VoidCallback? onFileDownloaded;

  const MemoryView({
    Key? key,
    required this.memory,
    this.loopVideo = false,
    this.onVideoControllerInitialized,
    this.onFileDownloaded,
  }) : super(key: key);

  @override
  State<MemoryView> createState() => _MemoryViewState();
}

class _MemoryViewState extends State<MemoryView> {
  MemoryFetchStatus status = MemoryFetchStatus.downloading;
  Uint8List? data;
  Timer? _nextMemoryTimer;

  @override
  void initState() {
    super.initState();

    loadMemoryFile();
  }

  @override
  void dispose() {
    _nextMemoryTimer?.cancel();

    super.dispose();
  }

  Future<void> loadMemoryFile() async {
    final timeline = context.read<TimelineModel>();

    setState(() {
      status = MemoryFetchStatus.downloading;
    });

    try {
      final file = await widget.memory.downloadToFile();

      if (!mounted) {
        return;
      }

      final fileData = await file.readAsBytes();

      setState(() {
        status = MemoryFetchStatus.done;
        data = fileData;
      });

      if (widget.onFileDownloaded != null) {
        widget.onFileDownloaded!();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        status = MemoryFetchStatus.error;
      });

      _nextMemoryTimer = Timer(
        const Duration(seconds: 1),
        timeline.nextMemory,
      );

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (status == MemoryFetchStatus.error) {
      return Center(
        child: Text(
          localizations.memoryViewDownloadFailed,
          style: platformThemeData(
            context,
            material: (data) => data.textTheme.bodyText2!.copyWith(
              color: Colors.white,
            ),
            cupertino: (data) => data.textTheme.textStyle.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (status == MemoryFetchStatus.done) {
      return Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          if (widget.memory.type == MemoryType.photo)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: RawMemoryDisplay(
                filename: widget.memory.filename,
                data: data!,
                type: widget.memory.type,
                loopVideo: widget.loopVideo,
                fit: BoxFit.cover,
              ),
            ),
          RawMemoryDisplay(
            filename: widget.memory.filename,
            data: data!,
            type: widget.memory.type,
            fit: BoxFit.contain,
            loopVideo: widget.loopVideo,
            onVideoControllerInitialized: widget.onVideoControllerInitialized,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PlatformCircularProgressIndicator(
          cupertino: (_, __) => CupertinoProgressIndicatorData(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: SMALL_SPACE),
        () {
          switch (status) {
            case MemoryFetchStatus.downloading:
              return Text(
                localizations.memoryViewIsDownloading,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodyText2!.copyWith(
                    color: Colors.white,
                  ),
                  cupertino: (data) => data.textTheme.textStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              );
            default:
              return const SizedBox();
          }
        }(),
      ],
    );
  }
}
