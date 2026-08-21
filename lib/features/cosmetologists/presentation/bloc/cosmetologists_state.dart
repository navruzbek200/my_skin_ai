part of 'cosmetologists_cubit.dart';

abstract class CosmetologistsState {}

class CosmetologistsLoading extends CosmetologistsState {}

class CosmetologistsLoaded extends CosmetologistsState {
  final List<Cosmetolog> items;
  CosmetologistsLoaded(this.items);
}

/// Carries no message, for the same reason as `ProductsError`.
class CosmetologistsError extends CosmetologistsState {}
