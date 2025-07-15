class LaporanState {
  final bool isLoading;
  final List<Map<String, dynamic>> laporanList;
  final String? error;

  LaporanState({
    this.isLoading = false,
    this.laporanList = const [],
    this.error,
  });

  LaporanState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? laporanList,
    String? error,
  }) {
    return LaporanState(
      isLoading: isLoading ?? this.isLoading,
      laporanList: laporanList ?? this.laporanList,
      error: error,
    );
  }
}

