import 'package:floating_fullscreen_widget/views/settings/settings_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

part 'views_event.dart';

part 'views_state.dart';

class ViewsBloc extends Bloc<ViewsEvent, ViewsState> {
  final SettingsService settingsService = SettingsService();
  bool wasActive = true;
  late ViewsState prevView = SpaciousViewState();

  ViewsBloc() : super(SpaciousViewState()) {
    on<SwitchToSettingsEvent>((event, emit) async {
      wasActive = await windowManager.isVisible();
      prevView = state;

      await windowManager.setSize(SettingsService.settingsViewSize, animate: true);
      await windowManager.center(animate: true);
      await windowManager.setOpacity(1);
      await windowManager.show();

      emit(SettingsViewState());
    });

    on<SwitchToPreviousViewEvent>((event, emit) async {
      if (prevView is SpaciousViewState) {
        add(SwitchToSpaciousViewEvent());
      } else if (prevView is FlatViewState) {
        add(SwitchToFlatViewEvent());
      }
    });

    on<SwitchToSpaciousViewEvent>((event, emit) async {
      if (!wasActive) await windowManager.hide();
      settingsService.setMode(DisplayMode.spacious);
      emit(SpaciousViewState());
      await windowManager.setMinimumSize(SettingsService.spaciousWidgetViewSize);
      await windowManager.setSize(SettingsService.spaciousWidgetViewSize, animate: true);
      await windowManager.setPosition(settingsService.getSpaciousWidgetPos(), animate: true);
      await windowManager.setOpacity(settingsService.getOpacity());
    });

    on<SwitchToFlatViewEvent>((event, emit) async {
      if (!wasActive) await windowManager.hide();
      settingsService.setMode(DisplayMode.flat);
      emit(FlatViewState());
      await windowManager.setMinimumSize(SettingsService.flatWidgetViewSize);
      await windowManager.setSize(SettingsService.flatWidgetViewSize, animate: true);
      await windowManager.setPosition(settingsService.getFlatWidgetPos(), animate: true);
      await windowManager.setOpacity(settingsService.getOpacity());
    });
  }
}
