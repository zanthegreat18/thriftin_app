class AdminLaporanState {
  final bool isLoading;
  final List<Map<String, dynamic>> laporan;
  final String? error;

  AdminLaporanState({
    this.isLoading = false,
    this.laporan = const [],
    this.error,
  });

  AdminLaporanState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? laporan,
    String? error,
  }) {
    return AdminLaporanState(
      isLoading: isLoading ?? this.isLoading,
      laporan: laporan ?? this.laporan,
      error: error,
    );
  }
}
