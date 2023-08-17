part of 'activation_bloc.dart';

@immutable
abstract class ActivationState {}

class ActiveState extends ActivationState {}

class InactiveState extends ActivationState {}

class UpdateSettingsState extends ActivationState {}
