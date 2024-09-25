import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'child_location_event.dart';
part 'child_location_state.dart';

class ChildLocationBloc extends Bloc<ChildLocationEvent, ChildLocationState> {

  ChildLocationBloc()
      : super(const ChildLocationState(
            childLocation: LatLng(0.0, 0.0),
            address: 'Loading address...',
            polygonPoints: [],
            isDrawing: false)) {
    on<FetchChildLocation>(_onFetchChildLocation);
    on<UpdateAddress>(_onUpdateAddress);
    on<StartDrawing>(_onStartDrawing);
    on<AddPolygonPoint>(_onAddPolygonPoint);
    on<FinishDrawing>(_onFinishDrawing);
    on<CheckChildLocation>(_onCheckChildLocation);
  }

  // lấy vị trí của trẻ
  Future<void> _onFetchChildLocation(
      FetchChildLocation event, Emitter emit) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("childLocation");
      final snapshot = await ref.once();
      if (snapshot.snapshot.exists) {
        var data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        LatLng newLocation = LatLng(data['latitude'], data['longitude']);
        emit(state.copyWith(childLocation: newLocation));

        add(UpdateAddress(newLocation));
      }
    } catch (e) {
      emit(state.copyWith(childLocation: const LatLng(0.0, 0.0))); // Xử lý lỗi
    }
  }

  Future<void> _onUpdateAddress(UpdateAddress event, Emitter emit) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        event.location.latitude, event.location.longitude);
    if (placeMarks.isNotEmpty) {
      String address =
          "${placeMarks[0].street}, ${placeMarks[0].locality}, ${placeMarks[0].country}";
      emit(state.copyWith(address: address));
    }
  }

  void _onStartDrawing(StartDrawing event, Emitter emit) {
    emit(state.copyWith(isDrawing: true, polygonPoints: []));
  }

  void _onAddPolygonPoint(AddPolygonPoint event, Emitter emit) {
    List<LatLng> updatedPolygonPoints = List.from(state.polygonPoints)
      ..add(event.point);
    emit(state.copyWith(polygonPoints: updatedPolygonPoints));
  }

  void _onFinishDrawing(FinishDrawing event, Emitter emit) {
    if (state.polygonPoints.length >= 3) {
      emit(state.copyWith(isDrawing: false));
      add(CheckChildLocation());
    } else {
      // Hiển thị thông báo lỗi nếu không đủ điểm
    }
  }

  void _onCheckChildLocation(CheckChildLocation event, Emitter emit) {
    bool isInside = _isPointInPolygon(state.childLocation, state.polygonPoints);
    emit(state.copyWith(isInsideSafeZone: isInside));
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[(i + 1) % polygon.length];
      if (((p1.latitude <= point.latitude && point.latitude < p2.latitude) ||
              (p2.latitude <= point.latitude &&
                  point.latitude < p1.latitude)) &&
          (point.longitude <
              (p2.longitude - p1.longitude) *
                      (point.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersections++;
      }
    }
    return intersections.isOdd;
  }
}
