class BuyState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final List<dynamic> history;

  BuyState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.history = const [],
  });

  BuyState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    List<dynamic>? history,
  }) {
    return BuyState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      history: history ?? this.history,
    );
  }
}

