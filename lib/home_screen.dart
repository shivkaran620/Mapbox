import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'history_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Finder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _startController,
              decoration: const InputDecoration(
                labelText: 'Start Location',
              ),
            ),
            TextField(
              controller: _endController,
              decoration: const InputDecoration(
                labelText: 'End Location',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to results screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsScreen(
                      startLocation: _startController.text,
                      endLocation: _endController.text,
                    ),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to history screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              child: const Text('Saved Searches'),
            ),
          ],
        ),
      ),
    );
  }
}
