import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HourlyTimeline extends StatelessWidget {
  final DateTime day;
  final double hourHeight;
  final double quarterHourHeight;
  final Function(DateTime time)? onTimeSlotTap;
  final ScrollController? scrollController;

  const HourlyTimeline({
    Key? key,
    required this.day,
    this.hourHeight = 80.0,
    double? quarterHourHeight,
    this.onTimeSlotTap,
    this.scrollController,
  }) : 
    quarterHourHeight = quarterHourHeight ?? 80.0 / 4,
    super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();
    
    return Container(
      width: 80, // Fixed width for timeline
      child: ListView.builder(
        controller: scrollController,
        itemCount: timeSlots.length,
        itemBuilder: (context, index) {
          final timeSlot = timeSlots[index];
          final isHourMark = timeSlot.minute == 0;
          final isHalfHour = timeSlot.minute == 30;
          
          return Container(
            height: isHourMark ? hourHeight : quarterHourHeight,
            child: Stack(
              children: [
                // Time label (only on hour marks)
                if (isHourMark)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 8,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        DateFormat('HH:mm').format(timeSlot),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                // Half-hour mark
                if (isHalfHour)
                  Positioned(
                    top: 0,
                    right: 8,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        ':30',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                // Divider line
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: isHourMark ? 0 : 20,
                  child: Container(
                    height: 1,
                    color: isHourMark 
                        ? Theme.of(context).dividerColor
                        : Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
                // Tap area for time slot selection
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => onTimeSlotTap?.call(timeSlot),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<DateTime> _generateTimeSlots() {
    final slots = <DateTime>[];
    
    // Generate 24 hours with 15-minute increments
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        slots.add(DateTime(day.year, day.month, day.day, hour, minute));
      }
    }
    
    return slots;
  }
}