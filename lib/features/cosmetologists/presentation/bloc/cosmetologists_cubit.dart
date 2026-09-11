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
      // Same race as ProductsCubit.load: a Firestore read outliving the tab
      // that asked for it.
      if (isClosed) return;
      emit(CosmetologistsLoaded(items));
    } catch (_) {
      if (isClosed) return;
      emit(CosmetologistsError());
    }
  }
}
