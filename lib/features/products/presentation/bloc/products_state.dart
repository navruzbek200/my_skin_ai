part of 'products_cubit.dart';

abstract class ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> items;
  ProductsLoaded(this.items);
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}
