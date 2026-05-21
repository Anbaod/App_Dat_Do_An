import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class ChangeAddressView extends StatefulWidget {
  const ChangeAddressView({super.key});

  @override
  State<ChangeAddressView> createState() => _ChangeAddressViewState();
}

class _ChangeAddressViewState extends State<ChangeAddressView> {
  GoogleMapController? _controller;

  LatLng selectedLocation = const LatLng(11.3254, 106.4770);
  final TextEditingController txtAddress = TextEditingController();

  late List<MarkerData> _customMarkers;

  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    _updateMarker();

    _getAddressFromLatLng(selectedLocation);
  }

  void _updateMarker() {
    _customMarkers = [
      MarkerData(
        marker: Marker(
          markerId: const MarkerId('selected_location'),
          position: selectedLocation,
        ),
        child: _customMarker(),
      ),
    ];
  }

  Widget _customMarker() {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Image.asset(
            'assets/img/map_pin.png',
            width: 35,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Future<void> _searchAddress() async {
    String address = txtAddress.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập địa chỉ"),
        ),
      );
      return;
    }

    try {
      FocusScope.of(context).unfocus();

      setState(() {
        isSearching = true;
      });

      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy địa chỉ"),
          ),
        );
        return;
      }

      final location = locations.first;

      LatLng newPosition = LatLng(
        location.latitude,
        location.longitude,
      );

      setState(() {
        selectedLocation = newPosition;

        _updateMarker();
      });

      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Không tìm thấy địa chỉ, hãy nhập cụ thể hơn",
          ),
        ),
      );
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}";

        setState(() {
          txtAddress.text = address;
        });
      }
    } catch (e) {
      setState(() {
        txtAddress.text =
        "Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}";
      });
    }
  }

  void _onMapTap(LatLng position) {
    FocusScope.of(context).unfocus();

    setState(() {
      selectedLocation = position;
      _updateMarker();
    });

    _controller?.animateCamera(
      CameraUpdate.newLatLng(position),
    );

    _getAddressFromLatLng(position);
  }

  void _confirmAddress() {
    FocusScope.of(context).unfocus();

    Navigator.pop(context, {
      "address": txtAddress.text,
      "latitude": selectedLocation.latitude,
      "longitude": selectedLocation.longitude,
    });
  }

  @override
  void dispose() {
    txtAddress.dispose();
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCamera = CameraPosition(
      target: selectedLocation,
      zoom: 15,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        backgroundColor: TColor.white,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            "assets/img/btn_back.png",
            width: 20,
            height: 20,
          ),
        ),

        centerTitle: false,

        title: Text(
          "Thay đổi địa chỉ",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Stack(
        children: [

          CustomGoogleMapMarkerBuilder(
            customMarkers: _customMarkers,
            builder: (BuildContext context, Set<Marker>? markers) {

              if (markers == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return GoogleMap(
                mapType: MapType.normal,

                initialCameraPosition: initialCamera,

                compassEnabled: false,

                myLocationButtonEnabled: false,

                zoomControlsEnabled: false,

                markers: markers,

                onTap: _onMapTap,

                gestureRecognizers: {
                  Factory<PanGestureRecognizer>(
                        () => PanGestureRecognizer(),
                  ),
                  Factory<ScaleGestureRecognizer>(
                        () => ScaleGestureRecognizer(),
                  ),
                  Factory<TapGestureRecognizer>(
                        () => TapGestureRecognizer(),
                  ),
                },

                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              );
            },
          ),

          Positioned(
            top: 15,
            left: 16,
            right: 16,

            child: SafeArea(
              child: Material(
                elevation: 5,

                borderRadius: BorderRadius.circular(12),

                child: Container(
                  height: 55,

                  padding: const EdgeInsets.symmetric(horizontal: 8),

                  decoration: BoxDecoration(
                    color: TColor.white,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: TextField(
                    controller: txtAddress,

                    textInputAction: TextInputAction.search,

                    onSubmitted: (_) {
                      _searchAddress();
                    },

                    decoration: InputDecoration(
                      hintText: "Tìm thành phố hoặc địa chỉ",

                      border: InputBorder.none,

                      prefixIcon: Icon(
                        Icons.search,
                        color: TColor.primaryText,
                      ),

                      suffixIcon: isSearching
                          ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                          : IconButton(
                        onPressed: _searchAddress,
                        icon: Icon(
                          Icons.send,
                          color: TColor.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        color: TColor.white,

        padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),

        child: SafeArea(
          child: RoundButton(
            title: "Xác nhận địa chỉ",
            onPressed: _confirmAddress,
          ),
        ),
      ),
    );
  }
}