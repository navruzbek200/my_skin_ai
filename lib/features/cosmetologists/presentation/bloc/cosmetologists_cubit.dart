import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/features/cosmetologists/data/cosmetologist_repository.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';

part 'cosmetologists_state.dart';

class CosmetologistsCubit extends Cubit<CosmetologistsState> {
  CosmetologistsCubit() : super(CosmetologistsLoading());

  final _repo = CosmetologistRepository();

  Future<void> load() async {
    emit(CosmetologistsLoading());
    try {
      final items = await _repo.getCosmetologists();
      emit(CosmetologistsLoaded(items));
    } catch (_) {
      emit(CosmetologistsError("Kosmetologlarni yuklashda xato"));
    }
  }
}
