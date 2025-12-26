// lib/screens/admin/event_form_dialog.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/events_provider.dart';

class EventFormDialog extends StatefulWidget {
  final String? editEventId;
  const EventFormDialog({super.key, this.editEventId});

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _regLink = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  XFile? _image;
  String? _imageUrl; // For displaying existing or picked image
  bool _featured = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editEventId != null) {
      final prov = context.read<EventsProvider>();
      final e = prov.events.firstWhere(
        (el) => el.id == widget.editEventId,
        orElse: () => throw Exception('Not found'),
      );
      _title.text = e.title;
      _desc.text = e.description;
      _location.text = e.location;
      _regLink.text = e.registrationLink ?? '';
      _date = e.eventDate;
      _featured = e.isFeatured;
      _imageUrl = e.imageUrl; // Set existing image URL
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _location.dispose();
    _regLink.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final r = await p.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (r != null && mounted) {
      setState(() {
        _image = r;
        _imageUrl = null; // Clear existing URL when new image is picked
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prov = context.read<EventsProvider>();
    try {
      if (widget.editEventId == null) {
        await prov.createEvent(
          title: _title.text,
          description: _desc.text,
          eventDate: _date,
          location: _location.text,
          imageFile: _image,
          registrationLink: _regLink.text.isEmpty ? null : _regLink.text,
          isFeatured: _featured,
        );
      } else {
        // For update, include image if new one is selected
        final updateData = {
          'title': _title.text,
          'description': _desc.text,
          'event_date': _date.toIso8601String(),
          'location': _location.text,
          'registration_link': _regLink.text.isEmpty ? null : _regLink.text,
          'is_featured': _featured,
        };

        // If new image is selected, upload it first
        if (_image != null) {
          // Create a temporary event to upload image, then update
          final tempEvent = await prov.createEvent(
            title: _title.text,
            description: _desc.text,
            eventDate: _date,
            location: _location.text,
            imageFile: _image,
            registrationLink: _regLink.text.isEmpty ? null : _regLink.text,
            isFeatured: _featured,
          );
          if (tempEvent != null && tempEvent.imageUrl != null) {
            updateData['image_url'] = tempEvent.imageUrl;
          }
          // Delete the temp event
          if (tempEvent != null) {
            await prov.deleteEvent(tempEvent.id);
          }
        }

        await prov.updateEvent(widget.editEventId!, updateData);
      }
      if (!mounted) return;
      Navigator.of(context).pop(); // Close dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editEventId == null
                ? 'Event created!'
                : 'Event updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _selectDateTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!mounted || picked == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (!mounted) return;

    if (time != null) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Widget _buildImagePreview() {
    if (_image != null) {
      // Show picked image using memory (web compatible)
      return FutureBuilder<List<int>>(
        future: _image!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                Uint8List.fromList(snapshot.data!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else if (_imageUrl != null) {
      // Show existing image from URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: _imageUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 64),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.editEventId != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEditing ? 'Edit Event' : 'Create Event'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _location,
                        decoration: const InputDecoration(
                          labelText: 'Location *',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateTime,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _date.toLocal().toString().split('.').first,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _regLink,
                  decoration: const InputDecoration(
                    labelText: 'Registration Link (optional)',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _featured,
                          onChanged: (v) =>
                              setState(() => _featured = v ?? false),
                        ),
                        const Text('Mark as Featured'),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Pick Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF146EB4),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_image != null || _imageUrl != null) ...[
                  const SizedBox(height: 16),
                  _buildImagePreview(),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF146EB4),
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
