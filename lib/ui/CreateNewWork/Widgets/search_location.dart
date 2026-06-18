import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:airotrackgit/ui/utils/Widgets/NormalTextPoppins.dart';
import 'package:airotrackgit/ui/CreateNewWork/LocationPickerScreen.dart';
import 'package:airotrackgit/Controller/CreateNewWorkController.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class SearchLocationField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Size media;

  const SearchLocationField({
    super.key,
    required this.media,
    required this.hintText,
    required this.controller,
  });

  @override
  State<SearchLocationField> createState() => _SearchLocationFieldState();
}

class _SearchLocationFieldState extends State<SearchLocationField> {
  bool showSuggestions = false;
  bool isSearching = false;
  List<Map<String, dynamic>> searchResults = [];
  String? selectedLocationName;
  final Dio _dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  final String apiKey = "AIzaSyBP1YuOeIr9DdXXdVs-hYAsDe3Q3YmCHQE";

  @override
  void initState() {
    super.initState();
    selectedLocationName =
        widget.controller.text.isNotEmpty ? widget.controller.text : null;
  }

  Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        showSuggestions = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
      showSuggestions = true;
    });

    try {
      String autocompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:in";

      debugPrint("Searching places for: $query");
      final response = await _dio.get(autocompleteUrl);

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        List<dynamic> predictions = response.data['predictions'];
        debugPrint("Found ${predictions.length} predictions");
        List<Map<String, dynamic>> resultsWithAddresses = [];
        for (var prediction in predictions.take(5)) {
          try {
            String placeId = prediction['place_id'];
            String description = prediction['description'];
            String detailsUrl =
                "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey";
            final detailsResponse = await _dio.get(detailsUrl);
            if (detailsResponse.data['status'] == 'OK') {
              var location =
                  detailsResponse.data['result']['geometry']['location'];
              double lat = location['lat'];
              double lng = location['lng'];
              resultsWithAddresses.add({
                'location': Location(
                    latitude: lat, longitude: lng, timestamp: DateTime.now()),
                'address': description,
              });
            }
          } catch (e) {
            debugPrint("Error getting place details: $e");
          }
        }

        setState(() {
          searchResults = resultsWithAddresses;
          isSearching = false;
        });
      } else {
        debugPrint("API Error: ${response.data['status']}");
        setState(() {
          searchResults = [];
          isSearching = false;
          showSuggestions = query.length > 2;
        });
      }
    } catch (e) {
      debugPrint("Error searching locations: $e");
      setState(() {
        searchResults = [];
        isSearching = false;
        showSuggestions = query.length > 2;
      });
    }
  }

  Future<void> onLocationSelected(Location location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = _formatPlacemark(place);
        widget.controller.text = address;
        setState(() {
          selectedLocationName = address;
          showSuggestions = false;
        });
        final result = await Get.to(() => LocationPickerScreen(
              initialLocation: LatLng(location.latitude, location.longitude),
            ));
        if (result != null && result['address'] != null) {
          widget.controller.text = result['address'];
          // Persist lat/lng to controller so first-time selection is stored
          try {
            final c = Get.find<CreateNewWorkController>();
            final dynamic latRaw = result['latitude'];
            final dynamic lngRaw = result['longitude'];
            c.latitude = latRaw is String
                ? latRaw
                : (latRaw is num)
                    ? latRaw.toString()
                    : '';
            c.longitude = lngRaw is String
                ? lngRaw
                : (lngRaw is num)
                    ? lngRaw.toString()
                    : '';
            c.update();
          } catch (_) {}
          setState(() {
            selectedLocationName = result['address'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String _formatPlacemark(Placemark place) {
    List<String> addressParts = [];
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    return addressParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            filled: true,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins-Regular',
            ),
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.media.width * 0.03,
              vertical: widget.media.height * 0.015,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: colorPrimary),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.controller.text.isNotEmpty &&
                    selectedLocationName != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        selectedLocationName = null;
                        showSuggestions = false;
                      });
                    },
                  ),
                isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search, color: Colors.black),
              ],
            ),
          ),
          onTap: () {
            if (selectedLocationName != null &&
                widget.controller.text.contains(', ')) {
              widget.controller.text = '';
            }
          },
          onChanged: (value) {
            searchLocations(value);
          },
        ),
        if (showSuggestions && searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: BoxConstraints(
              maxHeight: widget.media.height * 0.25,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length > 10 ? 10 : searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final location = result['location'] as Location;
                final address = result['address'] as String;

                return InkWell(
                  onTap: () => onLocationSelected(location),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: colorPrimary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: NormalTextPoppins(
                            text: address,
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (showSuggestions && searchResults.isEmpty && !isSearching)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: NormalTextPoppins(
                text:
                    'No suggestions found. Try searching with complete address or tap "Choose on Map"',
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
