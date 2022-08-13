mixin Loadable {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setState(void Function() callback);

  Future<void> callWithLoading(Future<void> Function() callback) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await callback();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
