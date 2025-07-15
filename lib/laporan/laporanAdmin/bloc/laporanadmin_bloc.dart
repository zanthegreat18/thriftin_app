import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/laporan/laporanAdmin/bloc/laporanadmin_event.dart';
import 'package:thriftin_app/laporan/laporanAdmin/bloc/laporanadmin_state.dart';
import 'package:thriftin_app/services/admin_laporan_service.dart';

class AdminLaporanBloc extends Bloc<AdminLaporanEvent, AdminLaporanState> {
  final AdminLaporanService laporanService;

  AdminLaporanBloc(this.laporanService) : super(AdminLaporanState()) {
    on<FetchAllLaporan>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final data = await laporanService.fetchAllLaporan();
        emit(state.copyWith(isLoading: false, laporan: data));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<UpdateLaporanStatus>((event, emit) async {
      try {
        await laporanService.updateStatus(event.laporanId, event.status);
        final data = await laporanService.fetchAllLaporan();
        emit(state.copyWith(laporan: data));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    on<DeleteProdukDariLaporan>((event, emit) async {
      try {
        await laporanService.deleteProduk(event.produkId);
        final data = await laporanService.fetchAllLaporan();
        emit(state.copyWith(laporan: data));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
