import 'package:flutter/material.dart';
import 'global_background.dart';
import 'app_bar_widget.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainLayout({
    super.key,
    required this.child,
    this.currentPath = '',
  });

  @override
  Widget build(BuildContext context) {
    // For admin login, we want the background to go all the way to the top
    // behind the transparent app bar.
    final isAdminLogin = currentPath == '/admin/login';

    return Stack(
      children: [
        const RepaintBoundary(child: GlobalBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Add padding to top of child to account for AppBar height
              // UNLESS it's the admin login screen
              Padding(
                padding: EdgeInsets.only(
                  top: isAdminLogin 
                      ? 0 
                      : MediaQuery.of(context).padding.top + kToolbarHeight + 20,
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
