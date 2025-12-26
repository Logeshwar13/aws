// lib/screens/code_of_conduct_screen.dart
import 'package:flutter/material.dart';
import '../widgets/footer_widget.dart';

class CodeOfConductScreen extends StatelessWidget {
  const CodeOfConductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 20 : 60,
                vertical: isSmall ? 60 : 80,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF146EB4).withOpacity(0.1),
                    const Color(0xFF232F3E).withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF00FFFF), // Neon Cyan
                        Color(0xFF2979FF), // Electric Blue
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Code of Conduct',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: isSmall ? 36 : 48,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Building a Safe and Inclusive Community',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: isSmall ? 16 : 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 20 : 40,
                vertical: isSmall ? 40 : 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    theme: theme,
                    title: 'Importance',
                    content:
                        'We firmly believe in the value and importance of an environment where all AWS community members and event participants feel welcome and safe. This Code of Conduct explains what type of behavior we expect from AWS community members & event participants. The terms of this Code of Conduct are non-negotiable. We will not tolerate behavior that runs counter to this Code of Conduct.',
                    icon: Icons.stars,
                    isSmall: isSmall,
                  ),
                  const SizedBox(height: 40),
                  
                  _buildSection(
                    theme: theme,
                    title: 'Behavior',
                    icon: Icons.group,
                    isSmall: isSmall,
                    listItems: [
                      'You will behave in a way as to create a safe and supportive environment for all event participants.',
                      'You will not engage in disruptive speech or behavior or otherwise interfere with the event or other individuals\' participation in the event.',
                      'You will not engage in any form of harassing, offensive, discriminatory, or threatening speech or behavior, including (but not limited to) relating to race, gender, gender identity and expression, national origin, religion, disability, marital status, age, sexual orientation, military or veteran status, or other protected category.',
                      'You will comply with the instructions of event and venue staff. You will comply with all applicable laws.',
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  _buildSection(
                    theme: theme,
                    title: 'Scope',
                    content:
                        'We expect all event participants (including AWS employees, attendees, vendors, sponsors, speakers, volunteers, and guests) to uphold the principles of this Code of Conduct. This Code of Conduct covers the main event and all related events (social or otherwise).',
                    icon: Icons.people_outline,
                    isSmall: isSmall,
                  ),
                  const SizedBox(height: 40),
                  
                  _buildSection(
                    theme: theme,
                    title: 'Consequences',
                    content:
                        'If we believe that you are not complying with this Code of Conduct, we may deny you entry or require you to leave all event venue(s). All determinations are at our sole discretion. We will involve local law enforcement if we deem appropriate. If we deny you entry or require you to leave, you will not be eligible to receive a refund of any fees paid to us related to the event or related events. Breaches of this Code of Conduct may result in disqualification from participating in future events.',
                    icon: Icons.gavel,
                    isSmall: isSmall,
                  ),
                  const SizedBox(height: 40),
                  
                  _buildSection(
                    theme: theme,
                    title: 'Contact',
                    content:
                        'If you witness or are subjected to inappropriate behavior, or have concerns related to this Code of Conduct, please promptly contact AWS Cloud Club RIT through our contact page.',
                    icon: Icons.contact_support,
                    isSmall: isSmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // Footer
            const FooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    String? content,
    List<String>? listItems,
    required IconData icon,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 30),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF146EB4).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF146EB4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF146EB4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: isSmall ? 22 : 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (content != null)
            Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.6,
                fontSize: isSmall ? 15 : 16,
              ),
            ),
          
          if (listItems != null)
            ...listItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF146EB4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.6,
                        fontSize: isSmall ? 15 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}