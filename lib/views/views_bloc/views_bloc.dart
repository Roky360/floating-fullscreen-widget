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

  ViewsBloc() : super(WidgetViewState()) {
    on<SwitchToSettingsEvent>((event, emit) async {
      wasActive = await windowManager.isVisible();

      await windowManager.setSize(SettingsService.settingsViewSize, animate: true);
      await windowManager.center(animate: true);
      await windowManager.setOpacity(1);
      await windowManager.show();

      emit(SettingsViewState());
    });

    on<SwitchToWidgetEvent>((event, emit) async {
      if (!wasActive) await windowManager.hide();
      emit(WidgetViewState());
      await windowManager.setSize(SettingsService.widgetViewSize, animate: true);
      await windowManager.setPosition(settingsService.getWidgetPos(), animate: true);
      await windowManager.setOpacity(settingsService.getOpacity());

    });
  }
}
