// lib/widgets/app_bar_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final bool showAdmin;

  const AppBarWidget({
    super.key,
    this.showAdmin = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _routes = [
    '/',
    '/events',
    '/gallery',
    '/members',
    '/about',
    '/contact',
  ];

  @override
  void initState() {
    super.initState();
    // Admin route is no longer part of the tabs
    _tabController = TabController(length: _routes.length, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTabWithRoute();
  }

  @override
  void didUpdateWidget(AppBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No need to update tabs for admin anymore as it's an icon
    _syncTabWithRoute();
  }

  void _syncTabWithRoute() {
    try {
      final router = GoRouter.of(context);
      final currentPath = router.routerDelegate.currentConfiguration.uri.path;
      
      int newIndex = 0;
      // Find the matching route index
      for (int i = 0; i < _routes.length; i++) {
        final route = _routes[i];
        if (currentPath == route || 
            (route != '/' && currentPath.startsWith(route))) {
          newIndex = i;
          break;
        }
      }

      if (_tabController.index != newIndex) {
        _tabController.animateTo(newIndex);
      }
    } catch (e) {
      // Handle case where router might not be ready
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 1100;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isMobile = MediaQuery.of(context).size.width < 600;

    final content = SafeArea(
      bottom: false,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go('/'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo2.png',
                  height: 45,
                  width: 45,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF00FFFF), // Neon Cyan
                      Color(0xFF2979FF), // Electric Blue
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'AWS Cloud Club',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: isSmall
            ? _mobileMenu(context, isDark)
            : [
                _desktopTabBar(context, theme, true),
                const SizedBox(width: 8),
                _HoverIconButton(
                  icon: Icons.sports_esports,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00FFFF), // Neon Cyan
                      Color(0xFF2979FF), // Electric Blue
                    ],
                  ),
                  onPressed: () {
                    context.go('/?section=game');
                  },
                  tooltip: 'Play Game',
                ),
                if (widget.showAdmin) ...[
                  const SizedBox(width: 8),
                  _HoverIconButton(
                    icon: Icons.admin_panel_settings_outlined,
                    onPressed: () {
                      context.go('/admin/login');
                    },
                    tooltip: 'Admin Dashboard',
                  ),
                ],
                const SizedBox(width: 16),
              ],
      ),
    );

    if (isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.50)
                  : Colors.white.withOpacity(0.70),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _desktopTabBar(BuildContext context, ThemeData theme, bool isDark) {
    final tabs = [
      const Tab(text: 'Home'),
      const Tab(text: 'Events'),
      const Tab(text: 'Gallery'),
      const Tab(text: 'Members'),
      const Tab(text: 'About'),
      const Tab(text: 'Contact'),
      // Admin tab removed
    ];

    return SizedBox(
      width: 650, // Reduced width since Admin tab is gone
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0E2A56), // Dark Blue
                Color(0xFF1A4BA0), // Lighter Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(0.3), // Neon Cyan border
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.2), // Neon Cyan glow
                blurRadius: 12,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: (index) {
            context.go(_routes[index]);
          },
          tabs: tabs,
        ),
      ),
    );
  }

  List<Widget> _mobileMenu(BuildContext context, bool isDark) {
    return [
      _HoverIconButton(
        icon: Icons.sports_esports,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00FFFF), // Neon Cyan
            Color(0xFF2979FF), // Electric Blue
          ],
        ),
        onPressed: () {
          context.go('/?section=game');
        },
        tooltip: 'Play Game',
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: isDark ? Colors.white : Colors.black,
          size: 28,
        ),
        onPressed: () => _showMobileMenuDialog(context, isDark),
      ),
      const SizedBox(width: 8),
    ];
  }

  void _showMobileMenuDialog(BuildContext context, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A1A).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _mobileMenuItem(context, Icons.home_rounded, 'Home', '/', isDark),
                    _mobileMenuItem(context, Icons.event_rounded, 'Events', '/events', isDark),
                    _mobileMenuItem(context, Icons.collections_rounded, 'Gallery', '/gallery', isDark),
                    _mobileMenuItem(context, Icons.people_rounded, 'Members', '/members', isDark),
                    _mobileMenuItem(context, Icons.info_rounded, 'About', '/about', isDark),
                    _mobileMenuItem(context, Icons.contact_mail_rounded, 'Contact', '/contact', isDark),
                    if (widget.showAdmin)
                      _mobileMenuItem(context, Icons.admin_panel_settings_rounded, 'Admin', '/admin/login', isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Widget _mobileMenuItem(BuildContext context, IconData icon, String text, String route, bool isDark) {
    final isSelected = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path == route;
    final color = isDark ? Colors.white : Colors.black;
    final activeColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // Close dialog
        if (route == '/') {
           // Special handling for home to ensure full reset if needed, or just go
           context.go('/');
        } else {
           context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : color.withOpacity(0.8),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : color,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;
  final Gradient? gradient;

  const _HoverIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.gradient,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? theme.colorScheme.primary.withOpacity(0.12)
                : Colors.transparent,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: IconButton(
            icon: widget.gradient != null
                ? ShaderMask(
                    shaderCallback: (bounds) =>
                        widget.gradient!.createShader(bounds),
                    child: Icon(widget.icon, color: Colors.white),
                  )
                : Icon(widget.icon),
            color: widget.gradient != null
                ? null
                : (widget.color ??
                    (theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)),
            onPressed: widget.onPressed,
          ),
        ),
      ),
    );
  }
}
