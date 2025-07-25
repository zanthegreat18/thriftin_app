import 'dart:io';

abstract class ProductEvent {}

class ProductNameChanged extends ProductEvent {
  final String name;
  ProductNameChanged(this.name);
}

class ProductDescriptionChanged extends ProductEvent {
  final String description;
  ProductDescriptionChanged(this.description);
}

class ProductPriceChanged extends ProductEvent {
  final String price;
  ProductPriceChanged(this.price);
}

class ProductImagePicked extends ProductEvent {
  final File image;
  ProductImagePicked(this.image);
}

class ProductLocationPicked extends ProductEvent {
  final double lat;
  final double lng;
  ProductLocationPicked(this.lat, this.lng);
}

class ProductSubmitted extends ProductEvent {}

class ProductFetched extends ProductEvent {} // produk milik user

class ProductAllFetched extends ProductEvent {} // semua produk

class ProductSelected extends ProductEvent {
  final Map<String, dynamic> product;
  ProductSelected(this.product);
}

class ProductDeleted extends ProductEvent {
  final int productId;

  ProductDeleted(this.productId);
}

class ProductUpdated extends ProductEvent {}
