part of 'views_bloc.dart';

@immutable
abstract class ViewsEvent {}

class SwitchToSettingsEvent extends ViewsEvent {}

class SwitchToWidgetEvent extends ViewsEvent {}
