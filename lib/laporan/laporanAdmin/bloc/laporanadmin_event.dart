abstract class AdminLaporanEvent {}

class FetchAllLaporan extends AdminLaporanEvent {}

class UpdateLaporanStatus extends AdminLaporanEvent {
  final int laporanId;
  final String status;

  UpdateLaporanStatus({required this.laporanId, required this.status});
}

class DeleteProdukDariLaporan extends AdminLaporanEvent {
  final int produkId;

  DeleteProdukDariLaporan({required this.produkId});
}
