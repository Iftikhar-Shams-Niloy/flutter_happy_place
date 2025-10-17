import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/widgets/image_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;

  void _savePlace() {
    final enteredTitle = _titleController.text;
    if (enteredTitle.isEmpty || _selectedImage == null) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You cannot leave any field empty!",
            textAlign: TextAlign.center,
            textScaler: TextScaler.linear(1.5),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 2500),
        ),
      );
      return;
    }
    ref
        .read(userPlacesProvider.notifier) //* reads from the provider
        .addPlace(enteredTitle, _selectedImage!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Happy place added successfully!",
          textAlign: TextAlign.center,
          textScaler: TextScaler.linear(1.5),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 2500),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Which new place made you happy?",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Title"),
              controller: _titleController,
            ),

            const SizedBox(height: 16),

            ImageInput(
              onPickedImage: (image) {
                _selectedImage = image;
              },
            ),

            ElevatedButton.icon(
              onPressed: _savePlace,
              label: const Text("Add Place"),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
