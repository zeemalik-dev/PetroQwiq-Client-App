// // Automatic FlutterFlow imports
// import '/backend/backend.dart';
// import '/backend/schema/structs/index.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/widgets/index.dart'; // Imports other custom widgets
// import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// import 'package:flutter/material.dart';
// // Begin custom widget code
// // DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter/services.dart'; // For ByteData and other system services
// import 'package:google_maps_flutter/google_maps_flutter.dart'
//     as gmaps; // For Google Maps support
// import 'package:geolocator/geolocator.dart'; // For getting user location
// import 'package:permission_handler/permission_handler.dart'; // For handling location permissions
// import 'dart:async'; // For Completer and async operations
// import 'dart:typed_data'; // For Uint8List (used in image processing)
// import 'dart:ui' as ui; // For working with images and RepaintBoundary
// import 'dart:math'; // For mathematical calculations (sin, cos, atan2)
// import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore queries
// import 'package:flutter/rendering.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// class GoogleMapWidget extends StatefulWidget {
//   const GoogleMapWidget({
//     super.key,
//     this.width,
//     this.height,
//     this.action,
//   });

//   final double? width;
//   final double? height;
//   final Future Function(RestaurentRecord? restaurant)? action;

//   @override
//   State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
// }

// class _GoogleMapWidgetState extends State<GoogleMapWidget> {
//   Completer<gmaps.GoogleMapController> _controller = Completer();
//   gmaps.LatLng _center = gmaps.LatLng(34.0758869, -118.356562);
//   final Set<gmaps.Marker> _markers = {};
//   final double radius = 15.0; // 15km radius
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//   }

//   /// ✅ **Helper function to check distance**
//   bool _isWithinRadius(gmaps.LatLng center, gmaps.LatLng point) {
//     double distance = _calculateDistance(
//         center.latitude, center.longitude, point.latitude, point.longitude);
//     return distance <= radius;
//   }

//   /// ✅ **Earth distance calculation**
//   double _calculateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const double R = 6371;
//     double dLat = _toRadians(lat2 - lat1);
//     double dLon = _toRadians(lon2 - lon1);
//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_toRadians(lat1)) *
//             cos(_toRadians(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _toRadians(double degree) {
//     return degree * pi / 180;
//   }

//   // Future<gmaps.BitmapDescriptor> createCustomMarker(BuildContext context,
//   //     String? imagePath, List<String>? extraImages) async {
//   //   if (imagePath == null || imagePath.isEmpty) {
//   //     print("Error: Image path is null or empty!");
//   //     return gmaps.BitmapDescriptor.defaultMarker;
//   //   }

//   //   final GlobalKey repaintBoundaryKey = GlobalKey();
//   //   final double size = 50.0; // Smaller icon size

//   //   Widget markerWidget = RepaintBoundary(
//   //     key: repaintBoundaryKey,
//   //     child: Container(
//   //       width: size,
//   //       height: size,
//   //       decoration: BoxDecoration(
//   //         shape: BoxShape.circle,
//   //         border: Border.all(color: Colors.white, width: 2),
//   //         image: DecorationImage(
//   //           image: NetworkImage(imagePath),
//   //           fit: BoxFit.cover,
//   //         ),
//   //       ),
//   //     ),
//   //   );

//   //   // Insert into Overlay
//   //   OverlayEntry overlayEntry = OverlayEntry(
//   //     builder: (context) => Positioned(
//   //       left: -1000,
//   //       child: Material(
//   //         type: MaterialType.transparency,
//   //         child: markerWidget,
//   //       ),
//   //     ),
//   //   );

//   //   Overlay.of(context)?.insert(overlayEntry);

//   //   await Future.delayed(Duration(milliseconds: 300)); // Allow rendering

//   //   final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
//   //       as RenderRepaintBoundary?;

//   //   if (boundary == null) {
//   //     print("Error: RepaintBoundary is still null!");
//   //     overlayEntry.remove();
//   //     return gmaps.BitmapDescriptor.defaultMarker;
//   //   }

//   //   final ui.Image image =
//   //       await boundary.toImage(pixelRatio: 0.5); // Smaller pixel ratio
//   //   final ByteData? byteData =
//   //       await image.toByteData(format: ui.ImageByteFormat.png);

//   //   overlayEntry.remove();

//   //   if (byteData == null) {
//   //     print("Error: Image conversion failed!");
//   //     return gmaps.BitmapDescriptor.defaultMarker;
//   //   }

//   //   final Uint8List bytes = byteData.buffer.asUint8List();
//   //   return gmaps.BitmapDescriptor.fromBytes(bytes);
//   // }

//   // Future<gmaps.BitmapDescriptor> createCustomMarker(
//   //     BuildContext context, String? imagePath) async {
//   //   if (imagePath == null || imagePath.isEmpty) {
//   //     print("Error: Image path is null or empty!");
//   //     return gmaps.BitmapDescriptor.defaultMarker;
//   //   }

//   //   final GlobalKey repaintBoundaryKey = GlobalKey();
//   //   final Completer<gmaps.BitmapDescriptor> completer = Completer();
//   //   final double size = 100.0;

//   //   // Create the widget for capturing
//   //   final widgetToRender = Offstage(
//   //     child: RepaintBoundary(
//   //       key: repaintBoundaryKey,
//   //       child: Container(
//   //         width: size,
//   //         height: size,
//   //         decoration: BoxDecoration(
//   //           shape: BoxShape.circle,
//   //           border: Border.all(color: Colors.white, width: 2),
//   //           image: DecorationImage(
//   //             image: NetworkImage(imagePath),
//   //             fit: BoxFit.cover,
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );

//   //   // Insert into the widget tree after the current build cycle
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     final overlayState = Overlay.of(context);
//   //     final overlayEntry = OverlayEntry(
//   //       builder: (context) => Positioned(
//   //         left: -1000,
//   //         top: -1000,
//   //         child: Material(
//   //           type: MaterialType.transparency,
//   //           child: widgetToRender,
//   //         ),
//   //       ),
//   //     );

//   //     overlayState.insert(overlayEntry);

//   //     Future.microtask(() async {
//   //       final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
//   //           as RenderRepaintBoundary?;
//   //       if (boundary != null) {
//   //         final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
//   //         final ByteData? byteData =
//   //             await image.toByteData(format: ui.ImageByteFormat.png);
//   //         if (byteData != null) {
//   //           final Uint8List bytes = byteData.buffer.asUint8List();
//   //           completer.complete(gmaps.BitmapDescriptor.fromBytes(bytes));
//   //         } else {
//   //           print("Error: Image conversion failed!");
//   //           completer.complete(gmaps.BitmapDescriptor.defaultMarker);
//   //         }
//   //       } else {
//   //         print("Error: RepaintBoundary not found!");
//   //         completer.complete(gmaps.BitmapDescriptor.defaultMarker);
//   //       }
//   //     });
//   //   });

//   //   return completer.future;
//   // }

//   Future<gmaps.BitmapDescriptor> createCustomMarker(String imageUrl) async {
//     try {
//       final http.Response response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         final Uint8List bytes = response.bodyBytes;
//         return gmaps.BitmapDescriptor.fromBytes(bytes);
//       } else {
//         print("Failed to load network image: ${response.statusCode}");
//         return gmaps.BitmapDescriptor.defaultMarker;
//       }
//     } catch (e) {
//       print("Error fetching image: $e");
//       return gmaps.BitmapDescriptor.defaultMarker;
//     }
//   }

//   Future<List<int>> _resizeImage(
//       Uint8List imageBytes, int width, int height) async {
//     final result = await FlutterImageCompress.compressWithList(
//       imageBytes,
//       minWidth: width,
//       minHeight: height,
//       quality: 90,
//       rotate: 0,
//     );

//     return result;
//   }

//   // Future<void> loadMarkers(
//   //     context, List<RestaurentRecord> allRestaurants) async {
//   //   List<gmaps.Marker> newMarkers = [];
//   //   // Loop over each restaurant to process and create markers
//   //   for (var restaurant in allRestaurants) {
//   //     if (_isWithinRadius(
//   //         _center,
//   //         gmaps.LatLng(
//   //             restaurant.location!.latitude, restaurant.location!.longitude))) {
//   //       // Create a custom marker for the restaurant

//   //       gmaps.BitmapDescriptor customMarker = await createCustomMarker(
//   //           context,
//   //           // restaurant.influencer[0].photo ??
//   //           "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dscvr-23gsp4/assets/lbo83i6t0ixk/profile-pic.png",
//   //           [
//   //             "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dscvr-23gsp4/assets/lbo83i6t0ixk/profile-pic.png",
//   //             "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dscvr-23gsp4/assets/q3xrjlpohg7m/profile-pic_(1).png",
//   //             "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dscvr-23gsp4/assets/igkg704cwnuy/profile-pic_(2).png"
//   //           ]);
//   //       newMarkers.add(
//   //         gmaps.Marker(
//   //           markerId: gmaps.MarkerId(restaurant.name ?? 'Unknown'),
//   //           position: gmaps.LatLng(
//   //               restaurant.location!.latitude, restaurant.location!.longitude),
//   //           icon: customMarker,
//   //           infoWindow: gmaps.InfoWindow(title: restaurant.name ?? 'Unknown'),
//   //           onTap: () async {
//   //             await widget.action?.call(restaurant);
//   //           },
//   //         ),
//   //       );
//   //     }
//   //   }

//   //   // Update markers only after processing all restaurants
//   //   if (mounted) {
//   //     setState(() {
//   //       _markers.clear();
//   //       _markers.addAll(newMarkers);
//   //     });
//   //   }
//   // }

//   final Set<String> processedRestaurants = {};

//   Future<void> loadMarkers(
//       BuildContext context, List<RestaurentRecord> allRestaurants) async {
//     List<gmaps.Marker> newMarkers = [];

//     for (var restaurant in allRestaurants) {
//       if (!processedRestaurants.contains(restaurant.reference.id) &&
//           _isWithinRadius(
//               _center,
//               gmaps.LatLng(restaurant.location!.latitude,
//                   restaurant.location!.longitude))) {
//         processedRestaurants.add(restaurant.reference.id);

//         gmaps.BitmapDescriptor customMarker = await createCustomMarker(

//             // restaurant.photoUrl ??
//             "https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/dscvr-23gsp4/assets/lbo83i6t0ixk/profile-pic.png");

//         newMarkers.add(
//           gmaps.Marker(
//             markerId: gmaps.MarkerId(restaurant.name ?? 'Unknown'),
//             position: gmaps.LatLng(
//                 restaurant.location!.latitude, restaurant.location!.longitude),
//             icon: customMarker,
//             infoWindow: gmaps.InfoWindow(title: restaurant.name ?? 'Unknown'),
//             onTap: () async {
//               await widget.action?.call(restaurant);
//             },
//           ),
//         );
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _markers.clear();
//         _markers.addAll(newMarkers);
//       });
//     }
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return StreamBuilder<List<RestaurentRecord>>(
//   //     stream: queryRestaurentRecord(), // ✅ Firestore real-time stream
//   //     builder: (context, snapshot) {
//   //       if (!snapshot.hasData) {
//   //         return Center(child: CircularProgressIndicator());
//   //       }
//   //       loadMarkers(context, snapshot.data!);
//   //       return Scaffold(
//   //         body: gmaps.GoogleMap(
//   //           onMapCreated: (gmaps.GoogleMapController controller) {
//   //             _controller.complete(controller);
//   //           },
//   //           initialCameraPosition: gmaps.CameraPosition(
//   //             target: _center,
//   //             zoom: 14.0,
//   //           ),
//   //           markers: _markers,
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<RestaurentRecord>>(
//       stream: queryRestaurentRecord(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         // Load markers only once
//         if (_markers.isEmpty) {
//           loadMarkers(context, snapshot.data!);
//         }

//         return Scaffold(
//           body: _markers.isEmpty
//               ? Center(
//                   child: CircularProgressIndicator()) // Show loading if needed
//               : gmaps.GoogleMap(
//                   onMapCreated: (gmaps.GoogleMapController controller) {
//                     _controller.complete(controller);
//                   },
//                   initialCameraPosition: gmaps.CameraPosition(
//                     target: _center,
//                     zoom: 14.0,
//                   ),
//                   markers: _markers,
//                 ),
//         );
//       },
//     );
//   }
// }
