import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_happy_place/models/place.dart';
import 'package:flutter_happy_place/widgets/custom_item_card.dart';
import 'package:path_provider/path_provider.dart';
import 'add_place_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_places.dart';
import '../utils/file_utils.dart';

class PlacesDetailScreen extends ConsumerStatefulWidget {
  const PlacesDetailScreen({super.key, required this.place});

  final Place place;

  @override
  ConsumerState<PlacesDetailScreen> createState() => _PlacesDetailScreenState();
}

class _PlacesDetailScreenState extends ConsumerState<PlacesDetailScreen> {
  final GlobalKey _repaintKey = GlobalKey();

  Future<void> _captureAndSaveSnapshot() async {
    try {
      // Find the RenderRepaintBoundary
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture screen')),
        );
        return;
      }

      // Capture the image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process image')),
        );
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Show confirmation dialog before saving
      if (!mounted) return;
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save Screenshot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Do you want to save this screenshot to your device?'),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Image.memory(pngBytes, fit: BoxFit.contain),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (shouldSave != true || !mounted) return;

      // Save to device storage.
      // Try to save to public DCIM/Happy Place on Android so images are visible
      // in the gallery. If that fails (permissions / platform), fall back to
      // the app documents directory.
      File? savedFile;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'happy_place_${widget.place.title.replaceAll(' ', '_')}_$timestamp.png';

      try {
        if (Platform.isAndroid) {
          final dcimDir = Directory('/storage/emulated/0/DCIM/Happy Place');
          if (!await dcimDir.exists()) {
            await dcimDir.create(recursive: true);
          }
          final candidate = File('${dcimDir.path}/$fileName');
          await candidate.writeAsBytes(pngBytes);
          savedFile = candidate;
        }
      } catch (_) {
        // fall through to fallback below
        savedFile = null;
      }

      if (savedFile == null) {
        final directory = await getApplicationDocumentsDirectory();
        final candidate = File('${directory.path}/$fileName');
        await candidate.writeAsBytes(pngBytes);
        savedFile = candidate;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Screenshot saved to:\n${savedFile.path}'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final places = ref.watch(userPlacesProvider);
    Place place;
    try {
      place = places.firstWhere((p) => p.id == widget.place.id);
    } catch (_) {
      place = widget.place;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        actions: [
          IconButton(
            onPressed: _captureAndSaveSnapshot,
            tooltip: 'Download screenshot',
            icon: Icon(
              Icons.file_download_outlined,
              color: Theme.of(context).colorScheme.surfaceContainer,
              size: 32,
              ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddPlaceScreen(editingPlace: place),
                ),
              );
            },
            icon: Image(
              image: AssetImage("assets/icons/edit_icon.png"),
              height: 28,
              width: 28,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _repaintKey,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    final double spacing = 16.0;
                    final double cardWidth = (availableWidth - spacing) / 2;
                    final double cardHeight = screenHeight * 0.3;
                    return Row(
                      children: [
                        //* <--- Place Image Section --->
                        isValidImageFile(place.image)
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.all(16),
                                      child: Stack(
                                        children: [
                                          //* <--- Image --->
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: InteractiveViewer(
                                              panEnabled: true,
                                              scaleEnabled: true,
                                              child: Image(
                                                image: FileImage(place.image!),
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (context, error, stack) =>
                                                        const Icon(
                                                          Icons.error,
                                                          size: 100,
                                                        ),
                                              ),
                                            ),
                                          ),

                                          //* <--- Close button --->
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  Navigator.of(context).pop(),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: ImageCard(
                                  height: cardHeight,
                                  width: cardWidth,
                                  borderColor: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  shadowColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  imageProvider: isValidImageFile(place.image)
                                      ? FileImage(place.image!)
                                      : null,
                                ),
                              )
                            : PlaceHolderContainer(
                                cardHeight: cardHeight,
                                cardWidth: cardWidth,
                                cardText: 'No image',
                              ),

                        const SizedBox(width: 16),

                        //* <--- Map Snapshot Section --->
                        isValidImageFile(place.mapSnapshot)
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.all(16),
                                      child: Stack(
                                        children: [
                                          //* <--- Snapshot Image --->
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: InteractiveViewer(
                                              panEnabled: true,
                                              scaleEnabled: true,
                                              child: Image(
                                                image: FileImage(
                                                  place.mapSnapshot!,
                                                ),
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (context, error, stack) =>
                                                        const Icon(
                                                          Icons.error,
                                                          size: 100,
                                                        ),
                                              ),
                                            ),
                                          ),

                                          //* <--- Close button --->
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  Navigator.of(context).pop(),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: ImageCard(
                                  height: cardHeight,
                                  width: cardWidth,
                                  borderColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  shadowColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  imageProvider:
                                      isValidImageFile(place.mapSnapshot)
                                      ? FileImage(place.mapSnapshot!)
                                      : null,
                                ),
                              )
                            : PlaceHolderContainer(
                                cardHeight: cardHeight,
                                cardWidth: cardWidth,
                                cardText: 'No map snapshot',
                              ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.title,
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.details,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceHolderContainer extends StatelessWidget {
  const PlaceHolderContainer({
    super.key,
    required this.cardHeight,
    required this.cardWidth,
    this.cardText = 'No map snapshot',
  });

  final double cardHeight;
  final double cardWidth;
  final String cardText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      width: cardWidth,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary,
            blurRadius: 8,
            spreadRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        cardText,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
