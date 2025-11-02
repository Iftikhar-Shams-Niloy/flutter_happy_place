import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/widgets/image_input.dart';
import 'package:flutter_happy_place/widgets/location_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_snackbar.dart';

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
  File? _mapSnapshotFile;

  void _savePlace() {
    final enteredTitle = _titleController.text;
    if (enteredTitle.isEmpty || _selectedImage == null) {
      FocusScope.of(context).unfocus();
      CustomSnackbar.show(
        context,
        "You cannot leave any field empty!",
        isError: true,
      );
      return;
    }
    ref
        .read(userPlacesProvider.notifier) //* reads from the provider
        .addPlace(enteredTitle, _selectedImage!, _mapSnapshotFile);
    CustomSnackbar.show(
      context,
      "New happy place added successfully!",
      isError: false,
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
    const double radius = 10.0;
    const double borderWidth = 8.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.primary,
            ],
          ),
        ),
        padding: const EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(radius - borderWidth),
          ),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                "Which new place made you happy?",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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

                  ImageInputWidget(
                    onPickedImage: (image) {
                      _selectedImage = image;
                    },
                  ),

                  const SizedBox(height: 16),

                  LocationInputWidget(
                    onMapSnapshotPicked: (file) {
                      setState(() {
                        _mapSnapshotFile = file;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _savePlace,
                    label: const Text("Add Place"),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
