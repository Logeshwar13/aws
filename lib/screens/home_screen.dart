// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/hero_section.dart';
import '../widgets/featured_events_section.dart';
import '../models/event_model.dart';
import '../widgets/about_and_benefits_sections.dart';
import '../widgets/aws_info_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/game_section.dart';
import '../widgets/footer_widget.dart';
import '../providers/events_provider.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());
  final List<bool> _sectionVisible = List.generate(6, (_) => false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = GoRouterState.of(context);
      if (state.queryParams['section'] == 'game') {
        if (_sectionKeys[4].currentContext != null) {
          Scrollable.ensureVisible(
            _sectionKeys[4].currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    for (int i = 0; i < _sectionKeys.length; i++) {
      if (!_sectionVisible[i]) {
        final RenderBox? box =
            _sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          final screenHeight = MediaQuery.of(context).size.height;

          // Trigger when section is 70% visible in viewport
          if (position.dy < screenHeight * 0.7) {
            setState(() => _sectionVisible[i] = true);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsProv = context.watch<EventsProvider>();
    final events = eventsProv.events;

    // Filter featured events to check if we should show the section
    final now = DateTime.now();
    final featuredEvents = events
        .where((e) => e.isFeatured && (e.eventDate.isAfter(now) || e.eventDate.isAtSameMomentAs(now)))
        .take(3)
        .toList();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Hero section - always visible, no animation
          const HeroSection(),

          // Animated sections
          if (featuredEvents.isNotEmpty)
            _ScrollTriggeredReveal(
              key: _sectionKeys[0],
              isVisible: _sectionVisible[0],
              child: GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(20),
                child: FeaturedEventsSection(events: events),
              ),
            ),
          _ScrollTriggeredReveal(
            key: _sectionKeys[1],
            isVisible: _sectionVisible[1],
            child: const GlassContainer(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.all(20),
              child: AboutAndBenefitsSections(),
            ),
          ),
          _ScrollTriggeredReveal(
            key: _sectionKeys[2],
            isVisible: _sectionVisible[2],
            child: const GlassContainer(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.all(20),
              child: AwsInfoSection(),
            ),
          ),
          _ScrollTriggeredReveal(
            key: _sectionKeys[3],
            isVisible: _sectionVisible[3],
            child: const GlassContainer(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.all(20),
              child: const CtaSection(),
            ),
          ),
          _ScrollTriggeredReveal(
            key: _sectionKeys[4],
            isVisible: _sectionVisible[4],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GameSection(),
            ),
          ),

          const SizedBox(height: 60),

          // Footer - always at bottom
          const FooterWidget(),
        ],
      ),
    );
  }
}

// Widget that reveals content when scrolled into view
class _ScrollTriggeredReveal extends StatefulWidget {
  final Widget child;
  final bool isVisible;

  const _ScrollTriggeredReveal({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  State<_ScrollTriggeredReveal> createState() => _ScrollTriggeredRevealState();
}

class _ScrollTriggeredRevealState extends State<_ScrollTriggeredReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    
    if (widget.isVisible) {
      _controller.forward();
    } else {
      // Failsafe: Auto-reveal after a short delay if not already visible
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !widget.isVisible) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_ScrollTriggeredReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
