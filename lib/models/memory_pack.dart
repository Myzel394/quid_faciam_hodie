import 'package:share_location/foreign_types/memory.dart';

class MemoryPack {
  final List<Memory> _memories;

  const MemoryPack(this._memories);

  List<Memory> get memories => _memories;
}
