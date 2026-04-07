import 'package:admin_attendance/view_model/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_theme.dart';

class OfficeLocationPicker extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialRadius;

  const OfficeLocationPicker({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.initialRadius,
  });

  @override
  State<OfficeLocationPicker> createState() => _OfficeLocationPickerState();
}

class _OfficeLocationPickerState extends State<OfficeLocationPicker> {
  late GoogleMapController controller;
  late LatLng currentLatLng;
  late double currentRadius;

  @override
  void initState() {
    super.initState();
    currentLatLng = LatLng(widget.initialLatitude, widget.initialLongitude);
    currentRadius = widget.initialRadius;
  }

  Future<void> _goToCurrentLocation() async {
    final cubit = AdminCubit.get(context);
    final location = await cubit.getCurrentLocation();
    if (location != null) {
      setState(() {
        currentLatLng = location;
      });
      controller.animateCamera(CameraUpdate.newLatLngZoom(location, 16));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get current location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              circles: {
                Circle(
                  circleId: const CircleId('allowed_radius'),
                  center: currentLatLng,
                  radius: currentRadius,
                  fillColor: AppColors.primaryColor.withOpacity(0.2),
                  strokeColor: AppColors.primaryColor,
                  strokeWidth: 2,
                ),
              },
              onMapCreated: (googleController) {
                controller = googleController;
              },
              initialCameraPosition: CameraPosition(
                target: currentLatLng,
                zoom: 16,
              ),
              onCameraMove: (CameraPosition position) {
                setState(() {
                  currentLatLng = position.target;
                });
              },
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              myLocationEnabled: true,
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 35),
                child: Icon(Icons.location_on, size: 45, color: AppColors.primaryColor),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton.small(
                onPressed: _goToCurrentLocation,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: AppColors.primaryColor),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('Radius:'),
                    Expanded(
                      child: Slider(
                        value: currentRadius,
                        min: 10,
                        max: 500,
                        onChanged: (value) {
                          setState(() {
                            currentRadius = value;
                          });
                        },
                      ),
                    ),
                    Text('${currentRadius.toInt()} m'),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'latitude': currentLatLng.latitude,
                    'longitude': currentLatLng.longitude,
                    'radius': currentRadius,
                  });
                },
                child: const Text('Confirm Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
