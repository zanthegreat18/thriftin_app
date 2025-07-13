import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thriftin_app/services/product_service.dart';
import 'package:thriftin_app/Produk/product_local_db.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'package:thriftin_app/models/product_models.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService;
  final ProductLocalDB localDB = ProductLocalDB();

  ProductBloc(this.productService) : super(ProductState()) {
    on<ProductNameChanged>((e, emit) => emit(state.copyWith(name: e.name)));
    on<ProductDescriptionChanged>((e, emit) => emit(state.copyWith(description: e.description)));
    on<ProductPriceChanged>((e, emit) => emit(state.copyWith(price: e.price)));
    on<ProductImagePicked>((e, emit) => emit(state.copyWith(image: e.image)));
    on<ProductLocationPicked>((e, emit) => emit(state.copyWith(lat: e.lat, lng: e.lng)));
    on<ProductSelected>((e, emit) {
      final product = e.product;
      emit(state.copyWith(
        selectedProduct: product,
        name: product['nama_produk'] ?? '',
        description: product['deskripsi'] ?? '',
        price: (product['harga'] ?? '').toString(),
        lat: double.tryParse(product['lokasi_lat']?.toString() ?? ''),
        lng: double.tryParse(product['lokasi_lng']?.toString() ?? ''),
        image: null, // gambar hanya diupload kalau diganti
      ));
    });

    on<ProductSubmitted>(_onSubmitProduct);
    on<ProductUpdated>(_onUpdateProduct);
    on<ProductFetched>(_onFetchProducts);
    on<ProductAllFetched>(_onFetchAllProducts);
    on<ProductDeleted>(_onDeleteProduct);
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

  Future<void> _onUpdateProduct(ProductUpdated event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final selected = state.selectedProduct;
    if (selected == null) {
      emit(state.copyWith(isSubmitting: false, errorMessage: "Produk tidak ditemukan untuk update"));
      return;
    }

    try {
      await productService.updateProduct(
        id: selected['id'],
        nama: state.name,
        deskripsi: state.description,
        harga: int.parse(state.price),
        latitude: state.lat!,
        longitude: state.lng!,
        imageFile: state.image, // boleh null kalau gak diganti
      );
      emit(state.copyWith(isSubmitting: false, success: true, selectedProduct: null));
      add(ProductFetched()); // refresh list
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchProducts(ProductFetched event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final products = await productService.fetchProducts();
      final productModels = products.map((e) => Product.fromMap(e)).toList();
      await localDB.insertProducts(productModels);
      emit(state.copyWith(isSubmitting: false, productList: products));
    } catch (e) {
      final offlineProducts = await localDB.getProducts();
      if (offlineProducts.isNotEmpty) {
        final converted = offlineProducts.map((p) => p.toMap()).toList();
        emit(state.copyWith(isSubmitting: false, productList: converted));
      } else {
        emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onFetchAllProducts(ProductAllFetched event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final products = await productService.fetchAllProducts();
      final productModels = products.map((e) => Product.fromMap(e)).toList();
      await localDB.insertProducts(productModels);
      emit(state.copyWith(isSubmitting: false, productList: products));
    } catch (e) {
      final offlineProducts = await localDB.getProducts();
      if (offlineProducts.isNotEmpty) {
        final converted = offlineProducts.map((p) => p.toMap()).toList();
        emit(state.copyWith(isSubmitting: false, productList: converted));
      } else {
        emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onDeleteProduct(ProductDeleted event, Emitter<ProductState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await productService.deleteProduct(event.productId);
      await localDB.deleteProduct(event.productId);
      add(ProductFetched()); // refresh list produk
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}