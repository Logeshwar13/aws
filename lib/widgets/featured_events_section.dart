import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/event_model.dart';
import 'event_card.dart';
import 'gradient_text.dart';

class FeaturedEventsSection extends StatelessWidget {
  final List<EventModel> events;
  const FeaturedEventsSection({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final featured = events
        .where((e) => e.isFeatured && (e.eventDate.isAfter(now) || e.eventDate.isAtSameMomentAs(now)))
        .take(3)
        .toList();
    if (featured.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isSmall ? 20 : 40),
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: isMobile ? 28 : 32,
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
                child: GradientText(
                  'Featured Events',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : null,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700), // Gold
                      Color(0xFFFFE0B2), // Light Orange/White-ish
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 32),
          isSmall
              ? _mobileLayout(context, featured, theme, isMobile)
              : _desktopLayout(context, featured, theme, isMobile),
        ],
      ),
    );
  }

  Widget _desktopLayout(BuildContext context, List<EventModel> featured,
      ThemeData theme, bool isMobile) {
    return SizedBox(
      height: isMobile ? 340 : 400,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, __) => SizedBox(width: isMobile ? 16 : 20),
        itemBuilder: (context, i) {
          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              horizontalOffset: 50,
              child: FadeInAnimation(
                child: EventCard(
                  event: featured[i],
                  isLarge: true,
                  isMobile: isMobile,
                  onTap: () => context.go('/events'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mobileLayout(BuildContext context, List<EventModel> featured,
      ThemeData theme, bool isMobile) {
    return Column(
      children: featured.asMap().entries.map((entry) {
        return AnimationConfiguration.staggeredList(
          position: entry.key,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50,
            child: FadeInAnimation(
              child: Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 16 : 20),
                child: SizedBox(
                  height: isMobile ? 340 : 400,
                  child: EventCard(
                    event: entry.value,
                    isLarge: false,
                    isMobile: isMobile,
                    onTap: () => context.go('/events'),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}