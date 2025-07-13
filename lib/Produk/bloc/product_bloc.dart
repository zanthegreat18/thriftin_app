import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/services/product_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService;

  ProductBloc(this.productService) : super(ProductState()) {
    on<ProductNameChanged>((e, emit) => emit(state.copyWith(name: e.name)));
    on<ProductDescriptionChanged>((e, emit) => emit(state.copyWith(description: e.description)));
    on<ProductPriceChanged>((e, emit) => emit(state.copyWith(price: e.price)));
    on<ProductImagePicked>((e, emit) => emit(state.copyWith(image: e.image)));
    on<ProductLocationPicked>((e, emit) => emit(state.copyWith(lat: e.lat, lng: e.lng)));
    on<ProductSelected>((e, emit) {
      print("Selected product in BLoC: ${e.product['nama_produk']}");
      emit(state.copyWith(selectedProduct: e.product));
    });
    on<ProductSubmitted>(_onSubmitProduct);
    on<ProductFetched>(_onFetchProducts);
  }

  Future<void> _onSubmitProduct(ProductSubmitted event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await productService.uploadProduct(
        nama: state.name,
        deskripsi: state.description,
        harga: int.parse(state.price),
        latitude: state.lat!,
        longitude: state.lng!,
        imageFile: state.image!,
      );

      emit(state.copyWith(isSubmitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchProducts(ProductFetched event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final products = await productService.fetchProducts();
      emit(state.copyWith(isSubmitting: false, productList: products));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}