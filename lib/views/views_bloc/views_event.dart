part of 'views_bloc.dart';

@immutable
abstract class ViewsEvent {}

class SwitchToSettingsEvent extends ViewsEvent {}

class SwitchToPreviousViewEvent extends ViewsEvent {}

class SwitchToSpaciousViewEvent extends ViewsEvent {}

class SwitchToFlatViewEvent extends ViewsEvent {}
