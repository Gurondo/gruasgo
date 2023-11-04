part of 'user_bloc.dart';

class UserEvent {}

class OnSetMarker extends UserEvent{
  Marker? marker;
  OnSetMarker(this.marker);
}

class OnSetIsClicPin extends UserEvent{
  bool? isClickPin;
  OnSetIsClicPin(this.isClickPin);
}