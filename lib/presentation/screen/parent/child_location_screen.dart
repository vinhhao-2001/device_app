import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/utils/utils.dart';
import '../../../data/api/local/db_helper/parent_database.dart';
import '../../../data/api/remote/firebase/parent_firebase_api.dart';

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
    _loadSafeZone();
  }

  Future<void> _loadSafeZone() async {
    List<LatLng> safeZonePoints = await ParentDatabase().getSafeZone();
    setState(() {
      _polygonPoints.addAll(safeZonePoints);
      if (safeZonePoints.isNotEmpty) {
        _polygons.add(Polygon(
          polygonId: const PolygonId('safeZone'),
          points: safeZonePoints,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.5),
        ));
      }
    });
    await _fetchChildLocation();
    _polygonPoints.clear();
  }

  // icon của trẻ
  Future<void> _loadCustomMarkerIcon() async {
    _childIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(60, 60), devicePixelRatio: 2.5),
      'assets/images/child.png',
    );
  }

  Future<void> _fetchChildLocation() async {
    final model = await ParentFirebaseApi().getChildLocation();
    _childLocation = model.position;
    await _updateAddress(_childLocation);
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _childLocation, zoom: 15.0),
    ));
  }

  Future<void> _updateAddress(LatLng location) async {
    try {
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placeMarks.isNotEmpty) {
        final placeMark = placeMarks[0];
        setState(() {
          _address = Utils().formatAddress(placeMark);
        });
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw 'Không lấy được vị trí của trẻ';
      }
      rethrow;
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
        List<LatLng> convexHullPoints = Utils().getConvexHull(_polygonPoints);
        _polygons.add(Polygon(
          polygonId: const PolygonId('safeZone'),
          points: convexHullPoints,
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.5),
        ));

        ParentFirebaseApi().sendSafeZoneInfo(convexHullPoints);
        ParentDatabase().insertSafeZone(convexHullPoints);
        _polygonPoints.clear();
      } else {
        _polygonPoints.clear();
      }
      _isDrawing = !_isDrawing;
    });
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
              initialCameraPosition:
                  CameraPosition(target: _childLocation, zoom: 5.0),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Text(
                    _address.isEmpty ? AppText.loadingAddress : _address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _fetchChildLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text(AppText.update),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleDrawingMode,
                      icon: Icon(_isDrawing ? Icons.check : Icons.security),
                      label: Text(_isDrawing ? "Hoàn tất" : AppText.safeZone),
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
