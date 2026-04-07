import 'package:admin_attendance/core/theme/app_theme.dart';
import 'package:admin_attendance/features/settings/widgets/office_location_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:admin_attendance/view_model/admin_cubit.dart';

class OfficeLocationSection extends StatelessWidget {
  const OfficeLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = AdminCubit.get(context);
    double lat = cubit.officeLatitude;
    double lng = cubit.officeLongitude;
    double radius = cubit.officeRadius;
    
    LatLng latLng = LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Office Location',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: GoogleMap(
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              key: ValueKey('${lat}_$lng'),
              initialCameraPosition: CameraPosition(
                target: latLng,
                zoom: 16,
              ),
              mapType: MapType.normal,
              circles: {
                Circle(
                  circleId: const CircleId('office_radius'),
                  center: latLng,
                  radius: radius,
                  fillColor: AppColors.primaryColor.withOpacity(0.2),
                  strokeColor: AppColors.primaryColor,
                  strokeWidth: 2,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('office'),
                  position: latLng,
                  infoWindow: const InfoWindow(
                    title: 'Office Location',
                  ),
                ),
              },
              onTap: (location) async {
                final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => Dialog(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      child: OfficeLocationPicker(
                        initialLatitude: lat,
                        initialLongitude: lng,
                        initialRadius: radius,
                      ),
                    ),
                  ),
                );

                if (result != null) {
                  double newLat = result['latitude'];
                  double newLng = result['longitude'];
                  double newRadius = result['radius'];
                  cubit.updateOfficeLocation(newLat, newLng, newRadius);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

