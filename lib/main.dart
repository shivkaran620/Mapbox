import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mapreminderapp/home_screen.dart';
import 'package:mapreminderapp/permissionallow.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{

  await Hive.initFlutter();
  await Hive.openBox('search_history');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Finder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );

    /*return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );*/
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  final Location location = Location();
  Set<Marker> markers = {};
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  PermissionAllow permissionAllow = PermissionAllow();


  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getCurrentLocation();
    _initializeNotifications();
    _startLocationUpdates();
  }

  void _initializeNotifications() {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
     // iOS: IOSInitializationSettings(),
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _startLocationUpdates() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      for (Marker marker in markers) {
        double distance = _calculateDistance(
          currentLocation.latitude!,
          currentLocation.longitude!,
          marker.position.latitude,
          marker.position.longitude,
        );

        print("location update $distance");
        if (distance < 200) {
          _showNotification(marker.infoWindow.title!);
          markers.remove(marker);
        }
      }
    });
  }

  double _calculateDistance(
      double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const double earthRadius = 6371000; // in meters
    double dLat = _degToRad(endLatitude - startLatitude);
    double dLng = _degToRad(endLongitude - startLongitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(startLatitude)) * cos(_degToRad(endLatitude)) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  void _showNotification(String title) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('MapReminder', 'MapReminder',channelDescription:  'Location Reminder Save',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Location Reminder',
      'You are near $title',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _checkPermissions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showError('Location services are disabled.');
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showError('Location permissions are denied.');
        return;
      }else{
        permissionAllow.requestNotificationPermissions();
      }
    }
  }
  void _getCurrentLocation() async {
    try {
      var locationData = await location.getLocation();
      setState(() {
        currentLocation = locationData;
      });
    } catch (e) {
      _showError('Failed to get location.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _handleTap(LatLng tappedPoint) {
    _showAddReminderDialog(tappedPoint);
  }
  void _showAddReminderDialog(LatLng tappedPoint) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController addressController = TextEditingController();

        return AlertDialog(
          title: const Text('Set Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Location Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  markers.add(
                    Marker(
                      markerId: MarkerId(tappedPoint.toString()),
                      position: tappedPoint,
                      infoWindow: InfoWindow(
                        title: nameController.text,
                        snippet: addressController.text,
                      ),
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Location Reminder')),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 15,
        ),
        myLocationEnabled: true,
        markers: markers,
        onTap: _handleTap,
      ),
    );
  }
}
