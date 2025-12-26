// lib/widgets/about_and_benefits_sections.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'gradient_text.dart';

class AboutAndBenefitsSections extends StatelessWidget {
  const AboutAndBenefitsSections({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 900;
    final isMobile = screenWidth < 600;
    final cols = isMobile ? 1 : 2;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isSmall ? 20 : 40),
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        children: [
          _aboutSection(context, theme, isMobile),
          SizedBox(height: isMobile ? 40 : 60),
          _experienceSection(context, theme, isMobile),
          SizedBox(height: isMobile ? 40 : 60),
          _whoCanJoinSection(context, theme, isMobile),
          SizedBox(height: isMobile ? 40 : 60),
          _visionSection(context, theme, isMobile),
          SizedBox(height: isMobile ? 40 : 60),
          _benefitsSection(context, theme, cols, isMobile),
        ],
      ),
    );
  }

  Widget _sectionContainer({
    required BuildContext context,
    required Widget child,
    required bool isMobile,
    // Removed glowColor to keep design consistent
  }) {
    return isMobile
        ? Container(
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              color: Colors.black.withOpacity(0.9),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1), // Consistent blue glow
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  color: Colors.black.withOpacity(0.75),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.1), // Consistent blue glow
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
  }

  Widget _sectionHeader(
    ThemeData theme,
    String title,
    bool isMobile, {
    Color color = const Color(0xFFFF9900), // Default to Orange
  }) {
    return Row(
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
          child: GradientText(
            title,
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
    );
  }

  Widget _aboutSection(BuildContext context, ThemeData theme, bool isMobile) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: _sectionContainer(
            context: context,
            isMobile: isMobile,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(theme, 'What we’re about', isMobile),
                SizedBox(height: isMobile ? 8 : 12),
                Text(
                  'AWS Cloud Club – Sri Manakula Vinayagar Engineering College\nIgnite Innovation, Inspire Possibilities',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF00FFFF), // Neon Cyan
                      Color(0xFF2979FF), // Electric Blue
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'What this club represents',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 20,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                Text(
                  'Sri Manakula Vinayagar Engineering College now hosts the region’s first ever AWS Cloud Club, built to create a strong student community around modern cloud technologies. The club serves as a space where curiosity becomes skill, ideas become projects, and students support one another in learning the AWS ecosystem.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _experienceSection(BuildContext context, ThemeData theme, bool isMobile) {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: _sectionContainer(
            context: context,
            isMobile: isMobile,
            // Removed glowColor
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(theme, 'What you’ll experience', isMobile), // Uses default Orange
                SizedBox(height: isMobile ? 16 : 24),
                Text(
                  'Instead of focusing only on theory, the club brings students into hands-on exploration. You’ll dive into topics like AI, cybersecurity, analytics, and cloud transformation, understanding how these technologies solve real problems across industries.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : null,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'Meetups include demos, discussions, and team activities that allow you to learn at your own pace while building confidence through practice.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _whoCanJoinSection(BuildContext context, ThemeData theme, bool isMobile) {
    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: _sectionContainer(
            context: context,
            isMobile: isMobile,
            // Removed glowColor
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(theme, 'Who can join', isMobile), // Uses default Orange
                SizedBox(height: isMobile ? 16 : 24),
                Text(
                  'Anyone interested in understanding how today’s tech world works is welcome here.\nWhether you are familiar with cloud services or stepping into this domain for the first time, the club encourages learning through collaboration and experimentation.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _visionSection(BuildContext context, ThemeData theme, bool isMobile) {
    return AnimationConfiguration.staggeredList(
      position: 3,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(
          child: _sectionContainer(
            context: context,
            isMobile: isMobile,
            // Removed glowColor
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(theme, 'Our vision', isMobile), // Uses default Orange
                SizedBox(height: isMobile ? 16 : 24),
                Text(
                  'With the theme Ignite Innovation, Inspire Possibilities, the club aims to build a culture where students think creatively, develop solutions with purpose, and grow together as future cloud professionals.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefitsSection(
      BuildContext context, ThemeData theme, int cols, bool isMobile) {
    final benefits = [
      _BenefitData(
        Icons.build,
        'Practical Exposure',
        'Practical exposure to AWS tools and services.',
        const Color(0xFF146EB4),
      ),
      _BenefitData(
        Icons.work,
        'Career Opportunities',
        'Awareness of cloud-focused career opportunities.',
        const Color(0xFF00A1C9),
      ),
      _BenefitData(
        Icons.people,
        'Networking',
        'Interaction with mentors, professionals, and fellow enthusiasts.',
        const Color(0xFF232F3E),
      ),
      _BenefitData(
        Icons.trending_up,
        'Skill Growth',
        'Skills that help you stand out in internships and placements.',
        const Color(0xFF00FF88),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(theme, 'What you’ll gain', isMobile), // Uses default Orange
        SizedBox(height: isMobile ? 20 : 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: isMobile ? 12 : 20,
            mainAxisSpacing: isMobile ? 12 : 20,
            // Adjusted aspect ratio to make cards more compact (reduced height)
            childAspectRatio: cols == 1 ? 3.0 : 3.2,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, i) {
            return AnimationConfiguration.staggeredGrid(
              position: i,
              duration: const Duration(milliseconds: 600),
              columnCount: cols,
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: _benefitCard(benefits[i], theme, isMobile),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _benefitCard(_BenefitData data, ThemeData theme, bool isMobile) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: isMobile
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  color: Colors.black.withOpacity(0.9),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withValues(alpha: 0.1),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: _benefitCardContent(data, theme, isMobile),
              )
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                    color: Colors.black.withOpacity(0.75),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withValues(alpha: 0.1),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: _benefitCardContent(data, theme, isMobile),
                ),
              ),
      ),
    );
  }

  Widget _benefitCardContent(
      _BenefitData data, ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          data.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : null,
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFE0B2), // Light Orange/White-ish
            ],
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Expanded(
          child: Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: isMobile ? 13 : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _BenefitData(this.icon, this.title, this.description, this.color);
}
