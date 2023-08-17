import 'package:floating_fullscreen_widget/views/views_bloc/views_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:floating_fullscreen_widget/views/settings/settings_view.dart';
import 'package:floating_fullscreen_widget/views/widget_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewsBloc, ViewsState>(
      bloc: context.read<ViewsBloc>(),
      builder: (BuildContext context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: () {
            if (state is WidgetViewState) {
              return const WidgetView();
            } else {
              // settings state
              return const SettingsView();
            }
          }(),
        );
      },
    );
  }
}
