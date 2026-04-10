import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<DateTime> weekDays;
  final double hourHeight;
  final DateTime startHour;
  final DateTime endHour;
  final Function(DateTime day, DateTime time)? onTimeSlotTap;

  TimeSlotGrid({
    Key? key,
    required this.weekDays,
    this.hourHeight = 60.0,
    DateTime? startHour,
    DateTime? endHour,
    this.onTimeSlotTap,
  }) : 
    startHour = startHour ?? DateTime(2024, 1, 1, 6), // 6 AM
    endHour = endHour ?? DateTime(2024, 1, 1, 23), // 11 PM
    super(key: key);

  @override
  Widget build(BuildContext context) {
    final hours = _generateHours();
        return CustomScrollView(
      slivers: [
        // Week header with day names
        SliverToBoxAdapter(
          child: Container(
            height: 50,
            child: Row(
              children: [
                // Time column header
                SizedBox(
                  width: 60,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Time',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
                // Day headers
                ...weekDays.map((day) => Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(day),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          DateFormat('d').format(day),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: _isToday(day) ? FontWeight.bold : FontWeight.normal,
                            color: _isToday(day) ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
        // Time grid
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, hourIndex) {
              final hour = hours[hourIndex];
              return Container(
                height: hourHeight,
                child: Row(
                  children: [
                    // Time label
                    SizedBox(
                      width: 60,
                      child: Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('HH:mm').format(hour),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    // Time slots for each day
                    ...weekDays.map((day) => Expanded(
                      child: GestureDetector(
                        onTap: () => onTimeSlotTap?.call(day, hour),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    )),
                  ],
                ),
              );
            },
            childCount: hours.length,
          ),
        ),
      ],
    );
  }

  List<DateTime> _generateHours() {
    final hours = <DateTime>[];
    for (int hour = startHour.hour; hour <= endHour.hour; hour++) {
      hours.add(DateTime(2024, 1, 1, hour));
    }
    return hours;
  }

  bool _isToday(DateTime day) {
    final today = DateTime.now();
    return day.year == today.year && 
           day.month == today.month && 
           day.day == today.day;
  }
}