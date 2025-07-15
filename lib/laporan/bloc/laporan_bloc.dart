import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/services/laporan_service.dart';
import 'laporan_event.dart';
import 'laporan_state.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  final LaporanService service;

  LaporanBloc(this.service) : super(LaporanState()) {
    on<LaporanFetched>(_onFetched);
    on<LaporanSubmitted>(_onSubmitted);
    on<LaporanStatusUpdated>(_onStatusUpdated);
  }

  void _onFetched(LaporanFetched event, Emitter<LaporanState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final list = await service.fetchAllLaporan();
      emit(state.copyWith(laporanList: list, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onSubmitted(LaporanSubmitted event, Emitter<LaporanState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await service.submitLaporan(event.produkId, event.alasan);
      add(LaporanFetched());
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onStatusUpdated(LaporanStatusUpdated event, Emitter<LaporanState> emit) async {
    try {
      await service.updateStatus(event.laporanId, event.status);
      add(LaporanFetched());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

