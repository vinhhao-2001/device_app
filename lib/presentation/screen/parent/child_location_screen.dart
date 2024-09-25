import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';

class ChildLocationScreen extends StatefulWidget {
  const ChildLocationScreen({super.key});

  @override
  State<ChildLocationScreen> createState() => _ChildLocationScreenState();
}

class _ChildLocationScreenState extends State<ChildLocationScreen> {
  LatLng _childLocation = const LatLng(0.0, 0.0);
  GoogleMapController? _mapController;
  String _address = '';
  BitmapDescriptor? _childIcon;
  final Set<Polygon> _polygons = {};
  final List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcon();
    _fetchChildLocation();
  }

  Future<void> _loadCustomMarkerIcon() async {
    _childIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(60, 60), devicePixelRatio: 2.5),
      'assets/images/child.png',
    );
  }

  Future<void> _fetchChildLocation() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("childLocation");
    final snapshot = await ref.once();
    if (snapshot.snapshot.exists) {
      var data = snapshot.snapshot.value as Map;
      _childLocation = LatLng(data['latitude'], data['longitude']);
      await _updateAddress(_childLocation);
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _childLocation, zoom: 15.0),
      ));
      _checkChildLocation();
    }
  }

  Future<void> _updateAddress(LatLng location) async {
    List<Placemark> placeMarks =
    await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placeMarks.isNotEmpty) {
      setState(() {
        _address = "Vị trí của trẻ: ${placeMarks[0].street}, ${placeMarks[0].locality}";
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng point) {
    if (_isDrawing) setState(() => _polygonPoints.add(point));
  }

  void _toggleDrawingMode() {
    setState(() {
      if (_isDrawing && _polygonPoints.length > 2) {
        _polygons.add(Polygon(
          polygonId: const PolygonId('safeZone'),
          points: List.from(_polygonPoints),
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.5),
        ));
        _polygonPoints.clear();
        _checkChildLocation();
      }
      _isDrawing = !_isDrawing;
    });
  }

  void _checkChildLocation() {
    if (_polygonPoints.length < 3) return;
    bool isInside = _isPointInPolygon(_childLocation, _polygonPoints);
    if (!isInside) _handleOutsideZone();
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng p1 = polygon[i], p2 = polygon[(i + 1) % polygon.length];
      if (((p1.latitude <= point.latitude && point.latitude < p2.latitude) ||
          (p2.latitude <= point.latitude && point.latitude < p1.latitude)) &&
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
    // Xử lý khi trẻ ra khỏi vùng an toàn
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trẻ"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _childLocation, zoom: 15.0),
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
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
              },
              polygons: _polygons,
              onTap: _onMapTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(_address.isEmpty ? "Loading address..." : _address),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _fetchChildLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Cập nhật"),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleDrawingMode,
                      icon: Icon(_isDrawing ? Icons.check : Icons.security),
                      label: Text(_isDrawing ? "Hoàn tất" : "Vùng an toàn"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
