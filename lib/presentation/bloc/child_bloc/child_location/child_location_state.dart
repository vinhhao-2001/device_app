part of 'child_location_bloc.dart';

class ChildLocationState extends Equatable {
  final LatLng childLocation;
  final String address;
  final List<LatLng> polygonPoints;
  final bool isDrawing;
  final bool? isInsideSafeZone; // Nullable, chỉ cập nhật khi cần thiết

  const ChildLocationState({
    required this.childLocation,
    required this.address,
    required this.polygonPoints,
    required this.isDrawing,
    this.isInsideSafeZone,
  });

  ChildLocationState copyWith({
    LatLng? childLocation,
    String? address,
    List<LatLng>? polygonPoints,
    bool? isDrawing,
    bool? isInsideSafeZone,
  }) {
    return ChildLocationState(
      childLocation: childLocation ?? this.childLocation,
      address: address ?? this.address,
      polygonPoints: polygonPoints ?? this.polygonPoints,
      isDrawing: isDrawing ?? this.isDrawing,
      isInsideSafeZone: isInsideSafeZone ?? this.isInsideSafeZone,
    );
  }

  @override
  List<Object?> get props =>
      [childLocation, address, polygonPoints, isDrawing, isInsideSafeZone];
}
