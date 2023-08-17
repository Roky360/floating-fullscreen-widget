import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'activation_event.dart';

part 'activation_state.dart';

class ActivationBloc extends Bloc<ActivationEvent, ActivationState> {
  ActivationBloc() : super(ActiveState()) {
    on<ActivateEvent>((event, emit) {
      emit(ActiveState());
    });

    on<DeactivateEvent>((event, emit) {
      emit(InactiveState());
    });

    on<UpdateSettingsEvent>((event, emit) {
      emit(UpdateSettingsState());
    });
  }
}
