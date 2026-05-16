import 'package:autoshare/General/maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../General/app_drawer.dart';
import '../General/plan_your_ride.dart';
import '../General/exit_pop_up.dart';
import 'package:autoshare/services/api_service.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  CustomerHomePageState createState() => CustomerHomePageState();
}

class CustomerHomePageState extends State<CustomerHomePage> {

  String userName = '';
  String userId = '';

  LatLng? _currentLocation;

  final MapController _mapController = MapController();
  final LatLng _ahmedabad = const LatLng(23.0215374, 72.5800568);

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();

  final List<Map<String, String>> _addresses = [
    {'name': 'Irani Restaurant', 'distance': ''},
    {'name': 'Bus Stop', 'distance': ''},
    {'name': 'Grand Hyatt Towers', 'distance': ''},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Customer';
      userId = prefs.getString('userId') ?? '';
    });

    // Get real GPS location
    final location = await ApiService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = LatLng(
          location['latitude']!,
          location['longitude']!,
        );
        // Auto-fill pickup field with coordinates
        // We'll replace with address lookup later
        pickupController.text =
            '${location['latitude']!.toStringAsFixed(4)}, '
            '${location['longitude']!.toStringAsFixed(4)}';
      });
      // Move map to user's real location
      _mapController.move(_currentLocation!, 15);
    }
  }

  double _sheetExtent = 0.67;

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        handlePopResult(context, didPop, result);
      },
      child: Scaffold(
        drawer: AppDrawer(userType: 'Customer', userName: userName),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Customer Home Page',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color.fromARGB(255, 254, 187, 38),
        ),
        backgroundColor: const Color.fromARGB(255, 254, 187, 38),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AhmedabadMap(mapController: _mapController),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                bottom: screenHeight * _sheetExtent + 10,
                right: 20,
                child: FloatingActionButton(
                  heroTag: 'customer_home_fab',
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () {
                    _mapController.move(_ahmedabad, 14);
                  },
                  child: const Icon(Icons.my_location, color: Colors.black87),
                ),
              ),
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _sheetExtent = notification.extent;
                  });
                  return true;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.67,
                  minChildSize: 0.05,
                  maxChildSize: 0.67,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6)
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 5,
                                width: 40,
                                margin:
                                    const EdgeInsets.only(top: 5, bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Select Address',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Divider(thickness: 1, color: Colors.grey),
                              _buildTextField(
                                hint: 'Pickup Location',
                                prefixIcon: const Icon(
                                  Icons.gps_fixed,
                                  color: Color.fromARGB(255, 254, 187, 38),
                                ),
                                controller: pickupController,
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                hint: 'Dropoff Destination',
                                prefixIcon: const Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 254, 187, 38),
                                ),
                                controller: dropoffController,
                              ),
                              const SizedBox(height: 8),
                              const Divider(thickness: 1, color: Colors.grey),
                              ElevatedButton(
                                onPressed: (pickupController.text.isNotEmpty &&
                                        dropoffController.text.isNotEmpty)
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PlanYourRide(
                                              pickupLocation:
                                                  pickupController.text,
                                              dropoffLocation:
                                                  dropoffController.text,
                                              userType: 'customer',
                                              buttonText: 'Check for Autoricksaw',
                                              distance: 'Distance - 1.2km',
                                              pickupLat: _currentLocation?.latitude,
                                              pickupLng: _currentLocation?.longitude, 
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 254, 187, 38),
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: const Text('Next'),
                              ),
                              const SizedBox(height: 12),
                              ..._addresses.map(
                                (address) => ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  leading: const Icon(Icons.access_time,
                                      color: Colors.grey),
                                  title: Text(address['name']!),
                                  trailing: Text(
                                    address['distance']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required Widget prefixIcon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(50),
        child: TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 254, 187, 38), width: 2.0),
            ),
          ),
        ),
      ),
    );
  }
}
