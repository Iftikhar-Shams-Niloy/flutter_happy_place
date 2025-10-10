import 'package:flutter/material.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key});

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: Card(
        borderOnForeground: true,
        child: TextButton.icon(
          onPressed: () {},
          label: const Text("Take Picture"),
          icon: const Icon(Icons.camera_rounded),
        ),
      ),
    );
  }
}
