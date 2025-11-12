import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/file_utils.dart';

class ImageInputWidget extends StatefulWidget {
  const ImageInputWidget({
    super.key,
    required this.onPickedImage,
    this.initialImage,
  });

  //* onPickedImage function will be passed to the parent (AddPlaceScreen()) after it is executed
  final void Function(File image) onPickedImage;
  // Optional initial image to show (for edit mode)
  final File? initialImage;

  @override
  State<ImageInputWidget> createState() {
    return _ImageInputWidgetState();
  }
}

class _ImageInputWidgetState extends State<ImageInputWidget> {
  File? _selectedImage;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
    }
  }
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
      widget.onPickedImage(_selectedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Text("Nothing to show!");
    if (isValidImageFile(_selectedImage)) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stack) => Center(
            child: Icon(Icons.broken_image, size: 50),
          ),
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: content,
        ),

        const SizedBox(height: 4),

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
