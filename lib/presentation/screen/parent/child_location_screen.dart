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
  late GoogleMapController _mapController;
  String _address = '';
  BitmapDescriptor? _childIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcon();
    _fetchChildLocation();
  }

  Future<void> _loadCustomMarkerIcon() async {
    try {
      _childIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24), devicePixelRatio: 2.5),
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
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        _address =
            "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}"; // Customize the address format
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
          // Bọc GoogleMap bằng ClipRRect để tạo viền tròn
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0), // Bo tròn góc
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
                },
              ),
            ),
          ),
          const SizedBox(
              height: 10), // Tạo khoảng cách nhỏ giữa bản đồ và địa chỉ

          // Bọc địa chỉ trong Container để có viền và nền
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Màu nền
                borderRadius: BorderRadius.circular(10.0), // Bo góc
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Màu bóng mờ
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Độ dịch chuyển của bóng mờ
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.all(10.0), // Khoảng cách bên trong Container
              child: Text(
                _address.isEmpty
                    ? "Loading address..."
                    : _address, // Display address here
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
                  onPressed: _fetchChildLocation, // Manually fetch location
                  icon: const Icon(Icons.refresh),
                  label: const Text("Cập nhật"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
