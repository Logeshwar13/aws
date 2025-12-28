import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final bool isLarge;
  final bool isMobile;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.isLarge = false,
    this.isMobile = false,
    this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: widget.isLarge
            ? (widget.isMobile ? double.infinity : 420)
            : double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isMobile ? 16 : 20),
            color: theme.cardColor,
            // Gradient border effect
            gradient: _isHovered
                ? const LinearGradient(
                    colors: [
                      Color(0xFF071A3A),
                      Color(0xFF1A4BA0),
                      Color(0xFF00C9FF),
                      Color(0xFFFF9900),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF146EB4).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
              if (_isHovered)
                BoxShadow(
                  color: const Color(0xFFFF9900).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          // Padding for the border width
          padding: EdgeInsets.all(_isHovered ? 2.0 : 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isMobile ? 14 : 18),
              color: theme.cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(widget.isMobile ? 14 : 18),
                        ),
                        child: widget.event.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.event.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF146EB4)
                                            .withOpacity(0.3),
                                        const Color(0xFF00A1C9)
                                            .withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) {
                                  debugPrint('IMAGE LOAD ERROR: $url -> $error');
                                  return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF146EB4)
                                            .withOpacity(0.3),
                                        const Color(0xFF00A1C9)
                                            .withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.event, size: 64)),
                                );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF146EB4)
                                          .withOpacity(0.3),
                                      const Color(0xFF00A1C9)
                                          .withOpacity(0.2),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                    child: Icon(Icons.event, size: 64)),
                              ),
                      ),
                      if (widget.event.isFeatured)
                        Positioned(
                          top: widget.isMobile ? 8 : 12,
                          right: widget.isMobile ? 8 : 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                              size: widget.isMobile ? 16 : 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(widget.isMobile ? 10 : 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.event.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: widget.isMobile ? 14 : 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: widget.isMobile ? 6 : 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: widget.isMobile ? 12 : 14,
                                color: const Color(0xFF146EB4)),
                            SizedBox(width: widget.isMobile ? 4 : 5),
                            Expanded(
                              child: Text(
                                widget.event.formattedDateShort,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: widget.isMobile ? 10 : 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: widget.isMobile ? 4 : 5),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: widget.isMobile ? 12 : 14,
                                color: const Color(0xFF00A1C9)),
                            SizedBox(width: widget.isMobile ? 4 : 5),
                            Expanded(
                              child: Text(
                                widget.event.location,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: widget.isMobile ? 10 : 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: widget.isMobile ? 5 : 6),
                        // Horizontal chips for mode, time, and speakers
                        Wrap(
                          spacing: widget.isMobile ? 4 : 6,
                          runSpacing: widget.isMobile ? 4 : 6,
                          children: [
                            if (widget.event.mode != null)
                              _buildInfoChip(
                                icon: widget.event.mode == 'Online'
                                    ? Icons.laptop
                                    : Icons.people,
                                label: widget.event.mode!,
                                color: const Color(0xFF146EB4),
                              ),
                            if (widget.event.endTime != null)
                              _buildInfoChip(
                                icon: Icons.access_time,
                                label:
                                    '${widget.event.formattedTime} - ${widget.event.formattedEndTime}',
                                color: const Color(0xFF00A1C9),
                              ),
                            if (widget.event.speakers != null &&
                                widget.event.speakers!.isNotEmpty)
                              _buildInfoChip(
                                icon: Icons.mic,
                                label: widget.event.speakers!,
                                color: const Color(0xFFFF9900),
                                maxWidth: widget.isMobile ? 150 : 180,
                              ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            if (widget.event.registrationLink != null &&
                                widget.event.registrationLink!.isNotEmpty)
                              Expanded(
                                child: HoverButton(
                                  onPressed: () async {
                                    final uri = Uri.parse(
                                        widget.event.registrationLink!);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  isMobile: widget.isMobile,
                                  child: Text(
                                    'Register Now',
                                    style: TextStyle(
                                        fontSize: widget.isMobile ? 12 : 14),
                                  ),
                                ),
                              ),
                            if (widget.event.registrationLink != null &&
                                widget.event.registrationLink!.isNotEmpty)
                              const SizedBox(width: 8),
                            Expanded(
                              child: HoverButton(
                                onPressed: widget.onTap ??
                                    () => context.go('/events'),
                                isMobile: widget.isMobile,
                                child: Text(
                                  'View Details',
                                  style: TextStyle(
                                      fontSize: widget.isMobile ? 12 : 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    double? maxWidth,
  }) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 6 : 8,
        vertical: widget.isMobile ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: widget.isMobile ? 11 : 12, color: color),
          SizedBox(width: widget.isMobile ? 3 : 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: widget.isMobile ? 10 : 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: chip,
      );
    }
    return chip;
  }
}

class HoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isMobile;
  final Icon? icon;
  final bool isLarge;

  const HoverButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isMobile = false,
    this.icon,
    this.isLarge = false,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: widget.isLarge ? double.infinity : null,
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: widget.icon ?? const SizedBox.shrink(),
          label: widget.child,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovered
                ? const Color(0xFF00D4FF) // Vibrant Cyan
                : const Color(0xFF146EB4), // AWS Blue
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: widget.isMobile ? 10 : 12,
              horizontal: widget.isLarge ? 32 : 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: _isHovered ? 8 : 2,
          ),
        ),
      ),
    );
  }
}
