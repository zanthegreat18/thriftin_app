import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? _selectedPosition;
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  String _selectedAddress = "";

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Layanan lokasi tidak aktif")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Akses lokasi ditolak")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Akses lokasi ditolak permanen. Aktifkan dari pengaturan.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
      });
      _getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendapatkan lokasi: $e")),
      );
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _selectedAddress = "${placemark.name ?? ''} ${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      print("Error searching location: $e");
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  void _onLocationSelected(Location location) {
    LatLng newPosition = LatLng(location.latitude, location.longitude);
    setState(() {
      _selectedPosition = newPosition;
      _searchResults = [];
      _searchController.clear();
    });
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(newPosition, 16),
    );
    _getAddressFromLatLng(location.latitude, location.longitude);
  }

  void _onSave() {
    if (_selectedPosition != null) {
      Navigator.pop(context, _selectedPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pilih Lokasi",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _selectedPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Map Section
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedPosition!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        markers: {
                          Marker(
                            markerId: const MarkerId("picked"),
                            position: _selectedPosition!,
                          ),
                        },
                        onTap: _onMapTap,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                      ),
                      
                      // Search overlay
                      if (_searchResults.isNotEmpty)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final location = _searchResults[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on, color: Colors.blue),
                                  title: Text("${location.latitude}, ${location.longitude}"),
                                  onTap: () => _onLocationSelected(location),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Search and Info Section
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchLocation,
                            decoration: InputDecoration(
                              hintText: "Cari alamat...",
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _searchLocation("");
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Selected Address Info
                      if (_selectedAddress.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, 
                                         color: Colors.blue[600], size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Lokasi Dipilih:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedAddress,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Loading indicator
                      if (_isSearching)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      
                      // Save Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 7, 7, 7),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Pilih Lokasi Ini",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}