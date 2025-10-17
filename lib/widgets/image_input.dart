import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickedImage});

  //* onPickedImage function will be passed to the parent (AddPlaceScreen()) after it is executed
  final void Function(File image) onPickedImage;

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  void _captureImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (pickedImage == null) {
      return;
    } else {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }

    widget.onPickedImage(_selectedImage!);
  }

  void _chooseImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (pickedImage == null) {
      return;
    } else {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Text("Nothing to show!");
    if (_selectedImage != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 3),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: content,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: TextButton.icon(
                onPressed: _captureImage,
                label: const Text("Take Picture"),
                icon: const Icon(Icons.camera_rounded),
              ),
            ),
            Card(
              child: TextButton.icon(
                onPressed: _chooseImage,
                label: const Text("Choose Picture"),
                icon: const Icon(Icons.image),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
