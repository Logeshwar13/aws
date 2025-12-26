import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

class CustomImageCropper extends StatefulWidget {
  final Uint8List imageBytes;
  final VoidCallback onCancel;
  final Function(Uint8List) onCropped;

  const CustomImageCropper({
    super.key,
    required this.imageBytes,
    required this.onCancel,
    required this.onCropped,
  });

  @override
  State<CustomImageCropper> createState() => _CustomImageCropperState();
}

class _CustomImageCropperState extends State<CustomImageCropper> {
  final _controller = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 600,
        height: 600,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            // Header with icons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Crop Image',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                        tooltip: 'Cancel',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isCropping
                            ? null
                            : () {
                                setState(() => _isCropping = true);
                                _controller.crop();
                              },
                        icon: _isCropping
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check),
                        color: Colors.green,
                        tooltip: 'Crop',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Cropper
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Crop(
                  image: widget.imageBytes,
                  controller: _controller,
                  onCropped: (result) {
                    setState(() => _isCropping = false);
                    if (result is CropSuccess) {
                      widget.onCropped(result.croppedImage);
                    } else if (result is CropFailure) {
                      debugPrint('Crop failure: ${result.cause}');
                    }
                  },
                  aspectRatio: 1,
                  baseColor: theme.scaffoldBackgroundColor,
                  maskColor: Colors.black.withOpacity(0.5),
                  radius: 20,
                  interactive: true,

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
