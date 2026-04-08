import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_app/domain/usecases/get_tasks_by_completion_status.dart';

/// Callback for when filter values change
typedef OnFiltersChanged = void Function({
  DateTime? startDate,
  DateTime? endDate,
  CompletionStatusFilter? statusFilter,
});

/// Accessible search filters widget with comprehensive WCAG 2.1 AA compliance.
/// Provides date range filtering and completion status filtering with screen reader support.
class SearchFilters extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final CompletionStatusFilter statusFilter;
  final OnFiltersChanged onFiltersChanged;
  final bool isExpanded;

  const SearchFilters({
    super.key,
    this.startDate,
    this.endDate,
    this.statusFilter = CompletionStatusFilter.all,
    required this.onFiltersChanged,
    this.isExpanded = true,
  });

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late CompletionStatusFilter _statusFilter;
  
  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _statusFilter = widget.statusFilter;
  }

  @override
  void didUpdateWidget(SearchFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != oldWidget.startDate) _startDate = widget.startDate;
    if (widget.endDate != oldWidget.endDate) _endDate = widget.endDate;
    if (widget.statusFilter != oldWidget.statusFilter) _statusFilter = widget.statusFilter;
  }

  /// Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Show date picker and return selected date
  Future<DateTime?> _pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required String helpText,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      helpText: helpText,
      confirmText: 'Select',
      cancelText: 'Cancel',
    );
  }

  /// Handle start date selection
  void _selectStartDate() async {
    final selectedDate = await _pickDate(
      context: context,
      initialDate: _startDate,
      lastDate: _endDate ?? DateTime(2030),
      helpText: 'Select start date for filtering tasks',
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
      });
      
      _notifyFiltersChanged();
      _announceFilterChange('Start date set to ${_formatDate(selectedDate)}');
    }
  }

  /// Handle end date selection
  void _selectEndDate() async {
    final selectedDate = await _pickDate(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      helpText: 'Select end date for filtering tasks',
    );

    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
      
      _notifyFiltersChanged();
      _announceFilterChange('End date set to ${_formatDate(selectedDate)}');
    }
  }

  /// Handle status filter change
  void _updateStatusFilter(CompletionStatusFilter newFilter) {
    if (newFilter != _statusFilter) {
      setState(() {
        _statusFilter = newFilter;
      });
      
      _notifyFiltersChanged();
      _announceFilterChange('Status filter changed to ${_getStatusFilterLabel(newFilter)}');
    }
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _statusFilter = CompletionStatusFilter.all;
    });
    
    _notifyFiltersChanged();
    _announceFilterChange('All filters cleared');
  }

  /// Get human-readable label for status filter
  String _getStatusFilterLabel(CompletionStatusFilter filter) {
    switch (filter) {
      case CompletionStatusFilter.all:
        return 'All tasks';
      case CompletionStatusFilter.completed:
        return 'Completed tasks only';
      case CompletionStatusFilter.pending:
        return 'Pending tasks only';
    }
  }

  /// Notify parent about filter changes
  void _notifyFiltersChanged() {
    widget.onFiltersChanged(
      startDate: _startDate,
      endDate: _endDate,
      statusFilter: _statusFilter,
    );
  }

  /// Announce filter changes to screen readers per D-10, D-11
  void _announceFilterChange(String message) {
    SemanticsService.announce(message, ui.TextDirection.ltr);
  }

  /// Count active filters for display
  int _getActiveFilterCount() {
    int count = 0;
    if (_startDate != null) count++;
    if (_endDate != null) count++;
    if (_statusFilter != CompletionStatusFilter.all) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final activeFilterCount = _getActiveFilterCount();

    return Semantics(
      label: 'Search filters',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with filter count and clear button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters${activeFilterCount > 0 ? ' ($activeFilterCount active)' : ''}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (activeFilterCount > 0)
                    Semantics(
                      hint: 'Clears all active filters',
                      child: TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear all'),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date range section
              Text(
                'Date Range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  // Start date picker
                  Expanded(
                    child: Semantics(
                      label: 'Start date: ${_formatDate(_startDate)}',
                      hint: 'Double tap to select start date',
                      child: InkWell(
                        onTap: _selectStartDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatDate(_startDate),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: _startDate != null
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // End date picker
                  Expanded(
                    child: Semantics(
                      label: 'End date: ${_formatDate(_endDate)}',
                      hint: 'Double tap to select end date',
                      child: InkWell(
                        onTap: _selectEndDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatDate(_endDate),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: _endDate != null
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Completion status section
              Semantics(
                label: 'Filter by completion status',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion Status',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Status radio buttons
                    Column(
                      children: CompletionStatusFilter.values.map((filter) {
                        return Semantics(
                          inMutuallyExclusiveGroup: true,
                          checked: _statusFilter == filter,
                          child: RadioListTile<CompletionStatusFilter>(
                            title: Text(_getStatusFilterLabel(filter)),
                            value: filter,
                            groupValue: _statusFilter,
                            onChanged: (value) {
                              if (value != null) {
                                _updateStatusFilter(value);
                              }
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}