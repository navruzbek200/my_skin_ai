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
      emit(ProductsLoaded(items));
    } catch (_) {
      emit(ProductsError("Mahsulotlarni yuklashda xato"));
    }
  }
}
