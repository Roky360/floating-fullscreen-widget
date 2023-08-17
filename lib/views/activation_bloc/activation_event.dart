part of 'activation_bloc.dart';

@immutable
abstract class ActivationEvent {}

class ActivateEvent extends ActivationEvent {}

class DeactivateEvent extends ActivationEvent {}

class UpdateSettingsEvent extends ActivationEvent {}
