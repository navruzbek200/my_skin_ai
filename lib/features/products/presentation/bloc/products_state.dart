part of 'products_cubit.dart';

abstract class ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> items;
  ProductsLoaded(this.items);
}

/// Carries no message: there is one thing to say here, and the screen is the
/// only layer that knows which language to say it in.
class ProductsError extends ProductsState {}
