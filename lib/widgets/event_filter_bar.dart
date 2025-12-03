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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterTab(
            label: 'Upcoming',
            isSelected: currentFilter == EventFilterType.upcoming,
            onTap: () => onFilterChanged(EventFilterType.upcoming),
            isMobile: isMobile,
          ),
          _FilterTab(
            label: 'History',
            isSelected: currentFilter == EventFilterType.history,
            onTap: () => onFilterChanged(EventFilterType.history),
            isMobile: isMobile,
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
  final bool isMobile;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 32,
          vertical: isMobile ? 10 : 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF146EB4), Color(0xFF00A1C9)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
    );
  }
}
