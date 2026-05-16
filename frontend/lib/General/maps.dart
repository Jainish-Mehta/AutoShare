import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AhmedabadMap extends StatelessWidget {
  final MapController mapController;
  const AhmedabadMap({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    final LatLng ahmedabad = const LatLng(23.0215374, 72.5800568);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: ahmedabad,
        initialZoom: 13,
        minZoom: 12,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.autoricksaw',
        ),
        /*MarkerLayer(
          markers: [
            Marker(
              point: ahmedabad,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: Colors.red,
              ),
            ),
          ],
        ),*/
      ],
    );
  }
}
