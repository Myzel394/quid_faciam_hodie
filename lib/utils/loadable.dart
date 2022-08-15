import 'package:uuid/uuid.dart';

const uuid = Uuid();

mixin Loadable {
  static final String _generalLoadingID = '#_loadable-${uuid.v4()}';

  final Set<String> _IDs = <String>{};

  bool get isLoading => _IDs.contains(_generalLoadingID);
  bool getIsLoadingSpecificID(final String id) => _IDs.contains(id);
  bool getIsLoading(final String id) => isLoading || getIsLoadingSpecificID(id);

  void setState(void Function() callback);

  Future<void> callWithLoading(
    Future<void> Function() callback, [
    final String? id,
  ]) async {
    setState(() {
      _IDs.add(id ?? _generalLoadingID);
    });

    try {
      await callback();
    } finally {
      setState(() {
        _IDs.remove(id ?? _generalLoadingID);
      });
    }
  }
}
