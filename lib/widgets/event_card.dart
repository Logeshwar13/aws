import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
            ? (widget.isMobile ? double.infinity : 320)
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap ?? () => context.go('/events'),
                borderRadius: BorderRadius.circular(widget.isMobile ? 14 : 18),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: widget.isMobile ? 10 : 12,
                                    vertical: widget.isMobile ? 5 : 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B6B), // Vibrant Red
                                      Color(0xFFFF8E53), // Vibrant Orange
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Featured',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.isMobile ? 10 : 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.event.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF146EB4),
                                fontSize: widget.isMobile ? 15 : 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: widget.isMobile ? 4 : 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: widget.isMobile ? 13 : 15,
                                    color: const Color(0xFF146EB4)),
                                SizedBox(width: widget.isMobile ? 4 : 6),
                                Expanded(
                                  child: Text(
                                    widget.event.formattedDateShort,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: widget.isMobile ? 11 : 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.isMobile ? 4 : 6),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: widget.isMobile ? 13 : 15,
                                    color: const Color(0xFF00A1C9)),
                                SizedBox(width: widget.isMobile ? 4 : 6),
                                Expanded(
                                  child: Text(
                                    widget.event.location,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: widget.isMobile ? 11 : 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            HoverButton(
                              onPressed:
                                  widget.onTap ?? () => context.go('/events'),
                              isMobile: widget.isMobile,
                              child: Text(
                                'View Details',
                                style: TextStyle(
                                    fontSize: widget.isMobile ? 12 : 14),
                              ),
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
        ),
      ),
    );
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
