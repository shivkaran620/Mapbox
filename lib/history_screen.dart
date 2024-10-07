import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'results_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('search_history');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Searches'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No saved searches yet.'));
          } else {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                var search = box.getAt(index);
                return ListTile(
                  title: Text('From: ${search['start']} To: ${search['end']}'),
                  onTap: () {
                    // Navigate to results screen with saved locations
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultsScreen(
                          startLocation: search['start'],
                          endLocation: search['end'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}