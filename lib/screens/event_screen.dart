// lib/screens/event_screen.dart
// Re-trigger build
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/events_provider.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../widgets/footer_widget.dart';
import '../widgets/event_filter_bar.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EventsProvider>();
    final events = prov.filteredEvents;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;
    final isMobile = screenWidth < 600;
    final crossAxisCount = isMobile ? 1 : (isSmall ? 2 : 3);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : (isSmall ? 24 : 40),
                        vertical: isMobile ? 20 : 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _headerTitle(
                                        theme, isMobile, prov.filterType),
                                    const SizedBox(height: 16),
                                    EventFilterBar(
                                      currentFilter: prov.filterType,
                                      onFilterChanged: prov.setFilterType,
                                      isMobile: isMobile,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _headerTitle(
                                        theme, isMobile, prov.filterType),
                                    EventFilterBar(
                                      currentFilter: prov.filterType,
                                      onFilterChanged: prov.setFilterType,
                                      isMobile: isMobile,
                                    ),
                                  ],
                                ),
                          SizedBox(height: isMobile ? 20 : 24),
                          if (events.isEmpty)
                            _emptyState(context, theme)
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio:
                                    isMobile ? 0.85 : (isSmall ? 0.95 : 1.1),
                                crossAxisSpacing: isMobile ? 12 : 20,
                                mainAxisSpacing: isMobile ? 12 : 20,
                              ),
                              itemCount: events.length,
                              itemBuilder: (context, i) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: i,
                                  duration: const Duration(milliseconds: 600),
                                  columnCount: crossAxisCount,
                                  child: SlideAnimation(
                                    verticalOffset: 50,
                                    child: FadeInAnimation(
                                      child: _eventCard(
                                          context, events[i], theme, isMobile),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Spacer(),
                        FooterWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _emptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No events available',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for upcoming events!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(
      BuildContext context, EventModel event, ThemeData theme, bool isMobile) {
    return EventCard(
      event: event,
      isMobile: isMobile,
      onTap: () => _showEventDetails(context, event, theme),
    );
  }
  void _showEventDetails(
      BuildContext context, EventModel event, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: event.imageUrl!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (event.imageUrl != null) const SizedBox(height: 24),
                    Text(
                      event.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                        Icons.calendar_today, event.formattedDateShort, theme,
                        color: const Color(0xFF146EB4)),
                    const SizedBox(height: 12),
                    _detailRow(Icons.location_on, event.location, theme,
                        color: const Color(0xFF00A1C9)),
                    if (event.mode != null) ...[
                      const SizedBox(height: 12),
                      _detailRow(
                          event.mode == 'Online' ? Icons.laptop : Icons.people,
                          event.mode!,
                          theme,
                          color: const Color(0xFF146EB4)),
                    ],
                    if (event.endTime != null) ...[
                      const SizedBox(height: 12),
                      _detailRow(Icons.access_time, '', theme,
                          color: const Color(0xFF00A1C9),
                          customContent: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start: ${event.formattedTime}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF00A1C9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'End: ${event.formattedEndTime}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF00A1C9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )),
                    ] else ...[
                      const SizedBox(height: 12),
                      _detailRow(Icons.access_time, event.formattedTime, theme,
                          color: const Color(0xFF00A1C9)),
                    ],
                    if (event.speakers != null &&
                        event.speakers!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _detailRow(Icons.mic, event.speakers!, theme,
                          color: const Color(0xFFFF9900)),
                    ],
                    if (event.registrationLink != null) ...[
                      const SizedBox(height: 24),
                      HoverButton(
                        onPressed: () async {
                          final uri = Uri.parse(event.registrationLink!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        child: const Text('Register Now'),
                        isLarge: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, ThemeData theme,
      {Color? color, Widget? customContent}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: customContent ??
              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ),
      ],
    );
  }

  Widget _headerTitle(ThemeData theme, bool isMobile, EventFilterType type) {
    final title = type == EventFilterType.upcoming ? 'Upcoming Events' : 'Past Events';
    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: isMobile ? 32 : 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF146EB4),
                      Color(0xFF00A1C9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: isMobile ? 20 : null,
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


