import 'dart:io';

class ProductState {
  final String name;
  final String description;
  final String price;
  final File? image;
  final double? lat;
  final double? lng;
  final bool isSubmitting;
  final String? errorMessage;
  final bool success;
  final List<dynamic> productList;
  final Map<String, dynamic>? selectedProduct;

  ProductState({
    this.name = '',
    this.description = '',
    this.price = '',
    this.image,
    this.lat,
    this.lng,
    this.isSubmitting = false,
    this.errorMessage,
    this.success = false,
    this.productList = const [],
    this.selectedProduct,
  });

  ProductState copyWith({
    String? name,
    String? description,
    String? price,
    File? image,
    double? lat,
    double? lng,
    bool? isSubmitting,
    String? errorMessage,
    bool? success,
    List<dynamic>? productList,
    Map<String, dynamic>? selectedProduct,
  }) {
    return ProductState(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      success: success ?? this.success,
      productList: productList ?? this.productList,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }
}