import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/data/products_data.dart';
import 'package:real_beauty_ai/features/products/data/product_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit([ProductRepository? repo])
      : _repo = repo ?? ProductRepository(),
        super(ProductsLoading());

  final ProductRepository _repo;

  Future<void> load() async {
    emit(ProductsLoading());
    try {
      final items = await _repo.getProducts();
      // The catalogue is a network read, and the tab it feeds can be left
      // before it lands — closing the cubit mid-flight. Emitting then throws
      // "Cannot emit new states after calling close", which surfaced in
      // Crashlytics as a crash on a screen the person had already walked away
      // from.
      if (isClosed) return;
      emit(ProductsLoaded(items));
    } catch (_) {
      if (isClosed) return;
      emit(ProductsError());
    }
  }
}
