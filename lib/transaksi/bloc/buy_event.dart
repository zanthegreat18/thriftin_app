abstract class BuyEvent {}

class BuyProductRequested extends BuyEvent {
  final int produkId;
  final int jumlah;

  BuyProductRequested({required this.produkId, required this.jumlah});
}

class FetchBuyHistory extends BuyEvent {}
