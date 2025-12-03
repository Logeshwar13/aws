import 'package:flutter/material.dart';
import 'global_background.dart';
import 'app_bar_widget.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const RepaintBoundary(child: GlobalBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Add padding to top of child to account for AppBar height
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                ),
                child: child,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBarWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
