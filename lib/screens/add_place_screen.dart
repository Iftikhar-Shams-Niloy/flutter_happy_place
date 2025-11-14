import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/widgets/image_input.dart';
import 'package:flutter_happy_place/widgets/location_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_snackbar.dart';
import '../models/place.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key, this.editingPlace});

  final Place? editingPlace;

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  File? _selectedImage;
  File? _mapSnapshotFile;

  bool get isEditing => widget.editingPlace != null;

  void _savePlace() {
    final enteredTitle = _titleController.text;
    final enteredDetails = _detailsController.text;
    if (enteredTitle.isEmpty || enteredDetails.isEmpty) {
      FocusScope.of(context).unfocus();
      CustomSnackbar.show(
        context,
        "You cannot leave title or details field empty!",
        isError: true,
      );
      return;
    }
    if (isEditing) {
      final id = widget.editingPlace!.id;
      ref
          .read(userPlacesProvider.notifier)
          .updatePlace(
            id,
            enteredTitle,
            enteredDetails,
            _selectedImage ?? widget.editingPlace!.image,
            _mapSnapshotFile ?? widget.editingPlace!.mapSnapshot,
          );
      CustomSnackbar.show(
        context,
        "Place updated successfully!",
        isError: false,
      );
    } else {
      ref
          .read(userPlacesProvider.notifier) //*<--reads from the provider-->
          .addPlace(
            enteredTitle,
            enteredDetails,
            _selectedImage,
            _mapSnapshotFile,
          );
      CustomSnackbar.show(
        context,
        "New happy place added successfully!",
        isError: false,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //* <--- Prefill fields when editing --->
    final edit = widget.editingPlace;
    if (edit != null) {
      _titleController.text = edit.title;
      _detailsController.text = edit.details;
      _selectedImage = edit.image;
      _mapSnapshotFile = edit.mapSnapshot;
    }
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
                isEditing ? 'Edit Place' : 'Which new place made you happy?',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Title"),
                    maxLines: 1,
                    maxLength: 50,
                    controller: _titleController,
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    decoration: InputDecoration(
                      labelText: "Details",
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 3,
                    maxLines: null,
                    maxLength: 500,
                    controller: _detailsController,
                  ),

                  const SizedBox(height: 16),

                  ImageInputWidget(
                    initialImage: _selectedImage,
                    onPickedImage: (image) {
                      setState(() {
                        _selectedImage = image;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  LocationInputWidget(
                    initialMapSnapshot: _mapSnapshotFile,
                    onMapSnapshotPicked: (file) {
                      setState(() {
                        _mapSnapshotFile = file;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _savePlace,
                    label: Text(isEditing ? 'Save' : 'Add Place'),
                    icon: Icon(isEditing ? Icons.check : Icons.add),
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
