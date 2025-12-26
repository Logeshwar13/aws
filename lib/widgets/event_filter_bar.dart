import 'package:flutter/material.dart';
import '../providers/events_provider.dart';

class EventFilterBar extends StatelessWidget {
  final EventFilterType currentFilter;
  final Function(EventFilterType) onFilterChanged;
  final bool isMobile;

  const EventFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if "Upcoming" is selected for alignment
    final isUpcoming = currentFilter == EventFilterType.upcoming;
    
    // Dimensions
    final double height = isMobile ? 40 : 48;
    final double width = isMobile ? 240 : 300;
    // Account for 1px border on each side (total 2px)
    final double tabWidth = (width - 2) / 2;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Sliding Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: isUpcoming ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: tabWidth,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  colors: [Color(0xFF146EB4), Color(0xFF00A1C9)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A1C9).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Text Labels
          Row(
            children: [
              _FilterTab(
                label: 'Upcoming',
                isSelected: isUpcoming,
                onTap: () => onFilterChanged(EventFilterType.upcoming),
                width: tabWidth,
                isMobile: isMobile,
              ),
              _FilterTab(
                label: 'History',
                isSelected: !isUpcoming,
                onTap: () => onFilterChanged(EventFilterType.history),
                width: tabWidth,
                isMobile: isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final bool isMobile;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.width,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: width,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: isMobile ? 14 : 16,
              fontFamily: 'Inter', // Assuming Inter is used, fallback to default if not
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
