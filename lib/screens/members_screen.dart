// lib/screens/members_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/member_model.dart';
import '../providers/members_provider.dart';
import '../widgets/footer_widget.dart';

const _memberAccentStart = Color(0xFF1F3C88);
const _memberAccentEnd = Color(0xFF39A7C4);
const _memberAccentGradient = LinearGradient(
  colors: [_memberAccentStart, _memberAccentEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String? _expandedMemberId;

  void _toggleMember(String memberId) {
    setState(() {
      if (_expandedMemberId == memberId) {
        _expandedMemberId = null;
      } else {
        _expandedMemberId = memberId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;
    final isMobile = screenWidth < 600;

    final membersProv = context.watch<MembersProvider>();
    final members = membersProv.members.where((m) => m.isActive).toList();
    final loading = membersProv.loading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // 1. Header Section
          SliverToBoxAdapter(
            child: AnimationConfiguration.synchronized(
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : (isSmall ? 20 : 40),
                      vertical: isMobile ? 20 : 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: isMobile ? 32 : 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.tertiary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Our Members',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isMobile ? 20 : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 6 : 8),
                        Text(
                          'Meet the amazing team behind AWS Cloud Club',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isMobile ? 13 : null,
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Members List (Lazy Loaded)
          if (loading)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          else if (members.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Members will appear here once added by admins.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else if (isMobile)
            // Mobile: Simple SliverList
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final member = members[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 600),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: _EnhancedMemberCard(
                              member: member,
                              isMobile: isMobile,
                              isExpanded: _expandedMemberId == member.id,
                              onToggle: () => _toggleMember(member.id),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: members.length,
                ),
              ),
            )
          else
            // Desktop: Chunked SliverList to mimic Wrap but with lazy loading
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Chunk size of 8 members per "row" (or block)
                    // This prevents rendering ALL members at once in a single Wrap
                    const chunkSize = 8;
                    final startIndex = index * chunkSize;
                    final endIndex = (startIndex + chunkSize < members.length)
                        ? startIndex + chunkSize
                        : members.length;
                    
                    if (startIndex >= members.length) return null;

                    final chunk = members.sublist(startIndex, endIndex);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Wrap(
                        spacing: 40, // Increased spacing
                        runSpacing: 40, // Increased runSpacing
                        alignment: WrapAlignment.center, // Center alignment
                        children: chunk.asMap().entries.map((entry) {
                          final i = entry.key;
                          final member = entry.value;
                          final globalIndex = startIndex + i;

                          return AnimationConfiguration.staggeredList(
                            position: globalIndex,
                            duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              verticalOffset: 50,
                              child: FadeInAnimation(
                                child: SizedBox(
                                  width: 310,
                                  child: _EnhancedMemberCard(
                                    member: member,
                                    isMobile: isMobile,
                                    isExpanded: _expandedMemberId == member.id,
                                    onToggle: () => _toggleMember(member.id),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  childCount: (members.length / 8).ceil(),
                ),
              ),
            ),

          // 3. Footer
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
    );
  }
}

class _EnhancedMemberCard extends StatefulWidget {
  final MemberModel member;
  final bool isMobile;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _EnhancedMemberCard({
    required this.member,
    required this.isMobile,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<_EnhancedMemberCard> createState() => _EnhancedMemberCardState();
}

class _EnhancedMemberCardState extends State<_EnhancedMemberCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverEnter(PointerEvent details) {
    setState(() => _isHovered = true);
    _animationController.forward();
  }

  void _onHoverExit(PointerEvent details) {
    setState(() => _isHovered = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = widget.member;
    final isMobile = widget.isMobile;
    final hasImage =
        member.profileUrl != null && member.profileUrl!.trim().isNotEmpty;

    final socialLinks = [
      {
        'icon': 'assets/icons/linkedin1.png',
        'url': member.linkedinUrl,
        'label': 'LinkedIn'
      },
      {
        'icon': 'assets/icons/github1.png',
        'url': member.githubUrl,
        'label': 'GitHub'
      },
      {
        'icon': 'assets/icons/instagram1.png',
        'url': member.instagramUrl,
        'label': 'Instagram'
      },
    ].where((item) {
      final url = item['url']?.toString();
      return url != null && url.trim().isNotEmpty;
    }).toList();

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                  // Gradient Border Effect
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
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00C9FF).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : null,
                ),
                padding: EdgeInsets.all(_isHovered ? 2.0 : 0), // Border width
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                    color: Colors.black,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Image Section (Always Visible)
                      SizedBox(
                        height: isMobile ? 250 : 300, // Fixed height for image
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (hasImage)
                              CachedNetworkImage(
                                imageUrl: member.profileUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  debugPrint('MEMBER IMAGE ERROR: $url -> $error');
                                  return _avatarFallback(theme, member, isMobile);
                                },
                              )
                            else
                              _avatarFallback(theme, member, isMobile),
                            
                            // Gradient Overlay at bottom of image
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 80,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.50),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Name & Role on Image (Always visible)
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 60, // Leave space for icon
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Golden Gradient Name with Dark Blue Border
                                  Stack(
                                    children: [
                                      // Stroke Text (Border)
                                      Text(
                                        member.name.toUpperCase(),
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          fontSize: isMobile ? 20 : 24,
                                          letterSpacing: 1.2,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 3
                                            ..color = const Color(0xFF001F3F), // Dark Blue
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // Gradient Text (Fill)
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: [
                                            Color(0xFFFFD700), // Gold
                                            Color(0xFFFFA500), // Orange Gold
                                            Color(0xFFFFE5B4), // Pale Gold
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                        child: Text(
                                          member.name.toUpperCase(),
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            fontSize: isMobile ? 20 : 24,
                                            letterSpacing: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    member.role.toUpperCase(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Expand Icon
                            Positioned(
                              right: 16,
                              bottom: 16, // Align with text
                              child: AnimatedRotation(
                                turns: widget.isExpanded ? 0.25 : 0, // Rotate 90 deg
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios, // Pointing right
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. Details Section (Expandable)
                      AnimatedCrossFade(
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 16 : 24),
                          color: const Color(0xFF111111), // Slightly lighter black
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (member.bio != null &&
                                  member.bio!.trim().isNotEmpty) ...[
                                Text(
                                  'About',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  member.bio!.trim(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              
                              if (socialLinks.isNotEmpty) ...[
                                Text(
                                  'Connect',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  children: socialLinks
                                      .map((item) => _AnimatedSocialIcon(
                                            iconPath: item['icon'] as String,
                                            label: item['label'] as String,
                                            url: item['url']?.toString() ?? '',
                                            isMobile: isMobile,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        crossFadeState: widget.isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _avatarFallback(ThemeData theme, MemberModel member, bool isMobile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: _memberAccentGradient,
      ),
      child: Center(
        child: Text(
          member.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 22 : 28, // Adjusted for smaller container
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AnimatedSocialIcon extends StatefulWidget {
  final String iconPath;
  final String label;
  final String url;
  final bool isMobile;

  const _AnimatedSocialIcon({
    required this.iconPath,
    required this.label,
    required this.url,
    required this.isMobile,
  });

  @override
  State<_AnimatedSocialIcon> createState() => _AnimatedSocialIconState();
}

class _AnimatedSocialIconState extends State<_AnimatedSocialIcon>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.label,
        child: GestureDetector(
          onTap: () => _launchUrl(context, widget.url),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: SizedBox(
                    width: widget.isMobile ? 20 : 24,
                    height: widget.isMobile ? 20 : 24,
                    child: Image.asset(
                      widget.iconPath,
                      color: _isHovered ? _memberAccentEnd : Colors.white.withOpacity(0.8),
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to default icons if custom icons not found
                        IconData fallbackIcon = Icons.link;
                        if (widget.label.contains('LinkedIn')) {
                          fallbackIcon = Icons.business_center;
                        } else if (widget.label.contains('GitHub')) {
                          fallbackIcon = Icons.code;
                        } else if (widget.label.contains('Twitter')) {
                          fallbackIcon = Icons.alternate_email;
                        } else if (widget.label.contains('Website')) {
                          fallbackIcon = Icons.public;
                        }
                        return Icon(
                          fallbackIcon,
                          color: _isHovered
                              ? _memberAccentEnd
                              : Colors.white.withOpacity(0.8),
                          size: widget.isMobile ? 18 : 22,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid link')),
      );
      return;
    }
    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _HoverSkillTag extends StatefulWidget {
  final String skill;
  final bool isMobile;

  const _HoverSkillTag({required this.skill, required this.isMobile});

  @override
  State<_HoverSkillTag> createState() => _HoverSkillTagState();
}

class _HoverSkillTagState extends State<_HoverSkillTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 10 : 12,
          vertical: widget.isMobile ? 4 : 6,
        ),
        decoration: BoxDecoration(
          gradient: _isHovered
              ? _memberAccentGradient
              : LinearGradient(
                  colors: [
                    theme.cardColor,
                    theme.cardColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? Colors.transparent
                : _memberAccentStart.withOpacity(0.35),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: _memberAccentStart.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          widget.skill,
          style: TextStyle(
            color: _isHovered ? Colors.white : Colors.cyanAccent,
            fontWeight: FontWeight.w500,
            fontSize: widget.isMobile ? 11 : 13,
          ),
        ),
      ),
    );
  }
}
