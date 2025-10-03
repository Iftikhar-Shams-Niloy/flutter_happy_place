import 'package:flutter/material.dart';

class PlacesScreen extends StatelessWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Places"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () {},
          ),
        ],
      ),

      body: Text("data"),
    );
  }
}
