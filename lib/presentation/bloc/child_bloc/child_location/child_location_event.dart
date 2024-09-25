part of 'child_location_bloc.dart';

sealed class ChildLocationEvent {}

class FetchChildLocation extends ChildLocationEvent {}

class UpdateAddress extends ChildLocationEvent {
  final LatLng location;

  UpdateAddress(this.location);
}

class StartDrawing extends ChildLocationEvent {}

class AddPolygonPoint extends ChildLocationEvent {
  final LatLng point;

  AddPolygonPoint(this.point);
}

class FinishDrawing extends ChildLocationEvent {}

class CheckChildLocation extends ChildLocationEvent {}
