part of 'cosmetologists_cubit.dart';

abstract class CosmetologistsState {}

class CosmetologistsLoading extends CosmetologistsState {}

class CosmetologistsLoaded extends CosmetologistsState {
  final List<Cosmetolog> items;
  CosmetologistsLoaded(this.items);
}

class CosmetologistsError extends CosmetologistsState {
  final String message;
  CosmetologistsError(this.message);
}
