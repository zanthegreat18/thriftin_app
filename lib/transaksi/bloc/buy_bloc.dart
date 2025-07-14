import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/services/auth_service.dart';
import 'package:thriftin_app/services/buy_service.dart';
import 'package:thriftin_app/transaksi/bloc/buy_event.dart';
import 'package:thriftin_app/transaksi/bloc/buy_state.dart';

// Buat ambil token

class BuyBloc extends Bloc<BuyEvent, BuyState> {
  final BuyService buyService;

  BuyBloc(this.buyService) : super(BuyState()) {
    on<BuyProductRequested>(_onBuyRequested);
    on<FetchBuyHistory>(_onFetchHistory);
  }

  Future<void> _onBuyRequested(BuyProductRequested event, Emitter<BuyState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final token = await AuthService.getToken();
      await buyService.buyProduct(
        produkId: event.produkId,
        jumlah: event.jumlah,
        token: token,
      );
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onFetchHistory(FetchBuyHistory event, Emitter<BuyState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final token = await AuthService.getToken();
      final history = await buyService.getBuyHistory(token);
      emit(state.copyWith(isLoading: false, history: history));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
