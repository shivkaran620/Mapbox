import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:hive/hive.dart';

class ResultsScreen extends StatefulWidget {
  final String startLocation;
  final String endLocation;

  const ResultsScreen({super.key, required this.startLocation, required this.endLocation});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  MapboxMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route from ${widget.startLocation} to ${widget.endLocation}'),
      ),
      body: Stack(
        children: [
          MapboxMap(
            accessToken: 'pk.eyJ1IjoiYWtoaWxsZXZha3VtYXIiLCJhIjoiY2x4MDcwYzZ4MGl2aTJqcmFxbXZzc3lndiJ9.9sxfvrADlA25b1CHX2VuDA',
            onMapCreated: (controller) {
              _controller = controller;
              // Add code to show route between start and end locations
            }, initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Example coordinates (San Francisco)
                zoom: 12.0,
              ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton(
              onPressed: () async {
                // Save search to Hive
                var box = Hive.box('search_history');
                await box.add({
                  'start': widget.startLocation,
                  'end': widget.endLocation,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search saved!')),
                );
              },
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}