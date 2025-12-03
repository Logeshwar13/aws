// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import '../widgets/about_and_benefits_sections.dart';
import '../widgets/footer_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 20),
            AboutAndBenefitsSections(),
            SizedBox(height: 40),
            FooterWidget(),
          ],
        ),
      ),
    );
  }
}