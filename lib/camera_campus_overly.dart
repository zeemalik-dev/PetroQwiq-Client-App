import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/overly_image_process.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

class CameraCompassOverlay extends StatefulWidget {
  @override
  _CameraCompassOverlayState createState() => _CameraCompassOverlayState();
}

class _CameraCompassOverlayState extends State<CameraCompassOverlay> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  double heading = 0.0;
  Position? position;
  String timestamp = "";
  XFile? capturedImage;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _timer;
  ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> capturedImages = [];
  final List<String> directions = [
    "N",
    "30",
    "60",
    "E",
    "120",
    "150",
    "S",
    "210",
    "240",
    "W",
    "300",
    "330"
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startCompassListener();
    _getLocation();
    _startTimestampUpdater();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        print("No cameras found.");
        return;
      }
      _cameraController =
          CameraController(cameras!.first, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _startCompassListener() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading == null) return;
      setState(() {
        heading = event.heading!;
      });
    });
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Location permission denied.");
      return;
    }
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          position = pos;
        });
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  void _startTimestampUpdater() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timestamp =
              DateFormat('dd MMM yyyy, hh:mm:ss a').format(DateTime.now());
        });
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Capture image
      XFile image = await _cameraController!.takePicture();

      // Read image as bytes
      Uint8List imageBytes = await image.readAsBytes();

      // Get GPS location
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String gpsCoordinates = "${pos.latitude}, ${pos.longitude}";

      // Get Compass Heading
      double heading = (await FlutterCompass.events?.first)?.heading ?? 0;
      String direction = "${heading.toStringAsFixed(2)}°";

      // Get Timestamp
      String timestamp =
          DateFormat('dd MMM yyyy, hh:mm:ss a').format(DateTime.now());

      // Get Altitude
      String altitude = "${pos.altitude.toStringAsFixed(2)} m";
      Uint8List? finalImage;
      // Apply overlays on the image
      await OverlayImageProcessor.applyOverlay(
        altitude: altitude,
        imageBytes: imageBytes,
        compassDirection: direction,
        latitude: position?.latitude.toStringAsFixed(6) ?? '--',
        longitude: position?.longitude.toStringAsFixed(6) ?? '--',
        timestamp: timestamp,
      ).then(
        (value) {
          finalImage = value!;
          // debugger();
        },
      );
      // Update UI with the overlayed image
      setState(() {
        capturedImage = image;
      });

      // Save the final image
      _askToSave(image, finalImage: finalImage);
    } catch (e) {
      print("Error capturing photo: $e");
    }
  }

  Future<void> _askToSave(XFile image, {Uint8List? finalImage}) async {
    bool? saveImage = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismiss
      builder: (context) => Dialog(
        backgroundColor: Colors.black, // Fullscreen black background
        insetPadding: EdgeInsets.zero, // Remove default padding
        child: Stack(
          children: [
            // Fullscreen Image
            Positioned.fill(
              child: finalImage != null
                  ? Image.memory(
                      finalImage!,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(image.path),
                      fit: BoxFit.cover, // Display full image
                    ),
            ),

            // Overlay for Image Data
            Positioned(
              bottom: 80,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "📍 Lat: ${position?.latitude.toStringAsFixed(6) ?? '--'}",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text(
                      "📍 Lng: ${position?.longitude.toStringAsFixed(6) ?? '--'}",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text("🧭 Heading: ${heading.toStringAsFixed(1)}°",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text("⏳ Time: $timestamp",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),

            // Cancel & Confirm Buttons with Minimal Spacing
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red, size: 40),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  SizedBox(width: 15), // Minimal spacing
                  IconButton(
                    icon:
                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (saveImage == true) {
      _savePhoto(image);
    } else {
      setState(() {
        capturedImage = null;
      });
    }
  }

  Future<String> getImageDimensionsAsString(String imagePath) async {
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      return "${decodedImage.width}x${decodedImage.height}";
    } else {
      return "Unknown";
    }
  }

  void _savePhoto(XFile image) async {
    String imagePath = image.path;
    String dimension = await getImageDimensionsAsString(imagePath);

    Map<String, dynamic> imageData = {
      "path": imagePath,
      "heading": heading.toStringAsFixed(1),
      "latitude": position?.latitude.toStringAsFixed(6),
      "longitude": position?.longitude.toStringAsFixed(6),
      "altitude": (position?.altitude ?? 0).toStringAsFixed(1),
      "timestamp": timestamp,
      "dimension": dimension,
    };

    setState(() {
      capturedImages.add(imageData);
      capturedImage = null;
    });
  }

  void _discardAllPhotos() {
    setState(() {
      capturedImages.clear();
    });
  }

  void _sendPhotos() {
    print("📤 Sending all images:");
    for (var i = 0; i < capturedImages.length; i++) {
      var image = capturedImages[i];
      print("Image ${i + 1}:");
      print("📂 Path: ${image['path']}");
      print("🧭 Heading: ${image['heading']}°");
      print("📍 GPS: ${image['latitude']}, ${image['longitude']}");
      print("📏 Altitude: ${image['altitude']}m");
      print("⏳ Timestamp: ${image['timestamp']}");
      print("🖼️ Dimensions: ${image['dimension']}");
    }
    _discardAllPhotos();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _compassSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: CameraPreview(_cameraController!)),

            // Compass Overlay
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: Colors.black54,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: directions.length * 10,
                          itemBuilder: (context, index) {
                            String label =
                                directions[index % directions.length];
                            return Container(
                              width: 50,
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: (label.length == 1) ? 18 : 12,
                                    fontWeight: (label.length == 1)
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          child: Container(width: 2, color: Colors.green),
                        ),
                      ],
                    ),
                  ),

                  // Location & Coordinates Bar
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    color: Colors.black54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("⬤ ${heading.toStringAsFixed(1)}°",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text(
                            "⬤ ${position?.latitude.toStringAsFixed(6)}, ${position?.longitude.toStringAsFixed(6)}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text(
                            "⬤ ${(position?.altitude ?? 0).toStringAsFixed(1)}m",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // GPS Location, Date & Time (Bottom Right)
            if (capturedImage == null)
              Positioned(
                bottom: 20,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("39 BEXLEY GROVE, SB SNZ",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(timestamp,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            // Capture Button
            // if (capturedImage == null)
            //   Positioned(
            //     bottom: 70,
            //     left: 0,
            //     right: 0,
            //     child: Center(
            //       child: FloatingActionButton(
            //         onPressed: _capturePhoto,
            //         child: Icon(Icons.camera_alt, size: 30),
            //       ),
            //     ),
            //   ),

            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: capturedImages.isNotEmpty
                  ? Container(
                      height: 80,
                      color: Colors.black54,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: capturedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(
                              File(capturedImages[index]['path']),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(),
            ),

            Positioned(
              bottom: capturedImages.isNotEmpty ? 200 : 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (capturedImages.isNotEmpty)
                    SizedBox(
                      width: 120, // Ensuring both buttons have the same width
                      child: ElevatedButton(
                        onPressed: _discardAllPhotos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              vertical: 12), // Uniform button height
                        ),
                        child: Text(
                          "Discard All",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  FloatingActionButton(
                    onPressed: _capturePhoto,
                    child: Icon(Icons.camera_alt, size: 30),
                  ),
                  if (capturedImages.isNotEmpty)
                    SizedBox(
                      width: 120, // Same width as "Discard All"
                      child: ElevatedButton(
                        onPressed: _sendPhotos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              vertical: 12), // Uniform button height
                        ),
                        child: Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (capturedImage == null)
              Positioned(
                bottom: 20,
                left: 10,
                child: Text("IWI BEDROOM1",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
