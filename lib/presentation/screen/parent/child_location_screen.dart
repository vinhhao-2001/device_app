import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../bloc/child_bloc/child_location/child_location_bloc.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  LatLng _childLocation = const LatLng(0.0, 0.0);
  late GoogleMapController _mapController;
  String _address = '';
  BitmapDescriptor? _childIcon;

  final Set<Polygon> _polygons = {};
  final List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;

  late ChildLocationBloc bloc;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcon();
    _fetchChildLocation();
    bloc = context.read<ChildLocationBloc>();
    bloc.add(FetchChildLocation());
  }

  Future<void> _loadCustomMarkerIcon() async {
    try {
      _childIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(60, 60), devicePixelRatio: 2.5),
        'assets/images/child.png',
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _fetchChildLocation() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("childLocation");
    final snapshot = await ref.once(); // Fetch data once
    if (snapshot.snapshot.exists) {
      var data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _childLocation = LatLng(data['latitude'], data['longitude']);
      });
      await _updateAddress(_childLocation);
      _moveCameraToChildLocation();
      _checkChildLocation(_polygonPoints);
    }
  }

  void _moveCameraToChildLocation() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _childLocation, zoom: 15.0),
      ),
    );
  }

  Future<void> _updateAddress(LatLng location) async {
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placeMarks.isNotEmpty) {
      setState(() {
        _address =
            "Vị trí của trẻ: ${placeMarks[0].street}, ${placeMarks[0].locality}, ${placeMarks[0].country}";
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _startDrawing() {
    setState(() {
      _isDrawing = true;
      _polygonPoints.clear();
      _polygons.clear();
    });
  }

  void _onMapTap(LatLng point) {
    if (_isDrawing) {
      setState(() {
        _polygonPoints.add(point);
      });
    }
  }

  void _finishDrawing() {
    if (_polygonPoints.length > 2) {
      List<LatLng> finalPolygonPoints = List.from(_polygonPoints);
      setState(() {
        _polygons.add(
          Polygon(
            polygonId: const PolygonId('safeZone'),
            points: finalPolygonPoints,
            strokeColor: Colors.blue,
            strokeWidth: 2,
            fillColor: Colors.blue.withOpacity(0.3),
          ),
        );
        _isDrawing = false;
      });
      _polygonPoints.clear();
      _checkChildLocation(finalPolygonPoints);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hãy chọn 3 điểm trở lên")),
      );
    }
  }

  void _checkChildLocation(List<LatLng> polygonPoints) {
    if (polygonPoints.length < 3) {
      return;
    }
    bool isInside = _isPointInPolygon(_childLocation, polygonPoints);
    if (!isInside) {
      _handleOutsideZone();
    }
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

  void _handleOutsideZone() {
    // Todo: Trẻ ở ngoài vùng an toàn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trẻ"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _childLocation,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("child"),
                  position: _childLocation,
                  icon: _childIcon ?? BitmapDescriptor.defaultMarker,
                ),
                for (int i = 0; i < _polygonPoints.length; i++)
                  Marker(
                    markerId: MarkerId('point_$i'),
                    position: _polygonPoints[i],
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              polygons: _polygons,
              onTap: _onMapTap,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Màu nền
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _address.isEmpty ? "Loading address..." : _address,
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _fetchChildLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Cập nhật"),
                ),
                ElevatedButton.icon(
                  onPressed: _isDrawing ? _finishDrawing : _startDrawing,
                  icon: Icon(_isDrawing ? Icons.check : Icons.security),
                  label:
                      Text(_isDrawing ? "Hoàn tất" : "Phạm vi an toàn cho trẻ"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
