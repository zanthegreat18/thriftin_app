abstract class LaporanEvent {}

class LaporanFetched extends LaporanEvent {}

class LaporanSubmitted extends LaporanEvent {
  final int produkId;
  final String alasan;

  LaporanSubmitted({required this.produkId, required this.alasan});
}

class LaporanStatusUpdated extends LaporanEvent {
  final int laporanId;
  final String status;

  LaporanStatusUpdated({required this.laporanId, required this.status});
}
