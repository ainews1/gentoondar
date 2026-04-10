import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';
import 'package:task_calendar_app/presentation/navigation/app_router.dart';

/// Form widget for creating and editing tasks.
/// Handles both create and edit modes based on optional Task parameter.
/// Provides validation, keyboard handling, and proper error feedback.
class TaskForm extends ConsumerStatefulWidget {
  /// Optional task for edit mode. If null, form is in create mode.
  final Task? task;

  const TaskForm({super.key, this.task});

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedDuration; // in minutes

  // Duration presets for dropdown
  static const List<int> _durationOptions = [
    15, 30, 45, 60, 90, 120, 180, 240, 300, 360, 420, 480
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Initialize form data based on create/edit mode
  void _initializeFormData() {
    if (widget.task != null) {
      // Edit mode - populate with existing task data
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _selectedDate = task.startTime.toLocal();
      _selectedTime = TimeOfDay.fromDateTime(task.startTime.toLocal());
      _selectedDuration = task.durationMinutes;
    } else {
      // Create mode - initialize with reasonable defaults
      final now = DateTime.now();
      _selectedDate = now;
      _selectedTime = TimeOfDay(
        hour: now.hour,
        minute: (now.minute ~/ 15) * 15, // Round to nearest 15 minutes
      );
      _selectedDuration = 60; // Default to 1 hour
    }
  }

  /// Get formatted date string for display
  String get _formattedDate {
    return DateFormat('MMM dd, yyyy').format(_selectedDate);
  }

  /// Get formatted time string for display
  String get _formattedTime {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Get formatted duration string for display
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    return '$hours hr $remainingMinutes min';
  }

  /// Show date picker dialog
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select task date',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Show time picker dialog
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Select task time',
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Combine selected date and time into DateTime
  DateTime _createDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  /// Validate and submit the form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final startTime = _createDateTime();
      final now = DateTime.now();

      final task = widget.task?.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        startTime: startTime,
        durationMinutes: _selectedDuration,
        updatedAt: now.toUtc(),
      ) ?? Task.create(
        id: 0, // Will be assigned by repository
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        startTime: startTime,
        durationMinutes: _selectedDuration,
        isCompleted: false,
      );

      if (widget.task != null) {
        // Edit existing task
        await ref.read(updateTaskProvider.notifier).updateTask(task);
      } else {
        // Create new task
        await ref.read(createTaskProvider.notifier).createTask(task);
      }

      // Check for errors
      final createState = ref.read(createTaskProvider);
      final updateState = ref.read(updateTaskProvider);
      
      if (createState.hasError || updateState.hasError) {
        final error = createState.error ?? updateState.error;
        _showErrorSnackBar(error.toString());
        return;
      }

      // Success - navigate back
      if (mounted) {
        AppNavigation.replaceWithHome(context);
        _showSuccessSnackBar(widget.task != null ? 'Task updated!' : 'Task created!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save task: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error snack bar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snack bar
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter task title',
                    helperText: 'Required, max 100 characters',
                  ),
                  textInputAction: TextInputAction.next,
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    if (value.trim().length > 100) {
                      return 'Title must not exceed 100 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter task description (optional)',
                    helperText: 'Optional, max 500 characters',
                    alignLabelWithHint: true,
                  ),
                  textInputAction: TextInputAction.newline,
                  maxLines: 3,
                  maxLength: 500,
                  validator: (value) {
                    if (value != null && value.length > 500) {
                      return 'Description must not exceed 500 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date selector
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      hintText: 'Select task date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _formattedDate,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time selector
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time *',
                      hintText: 'Select task time',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      _formattedTime,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Duration selector
                DropdownButtonFormField<int>(
                  initialValue: _selectedDuration,
                  decoration: const InputDecoration(
                    labelText: 'Duration *',
                    hintText: 'Select task duration',
                    suffixIcon: Icon(Icons.timer),
                  ),
                  items: _durationOptions.map((minutes) {
                    return DropdownMenuItem(
                      value: minutes,
                      child: Text(_formatDuration(minutes)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDuration = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value <= 0) {
                      return 'Duration is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading 
                            ? null 
                            : () => AppNavigation.goBack(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(widget.task != null ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Form info
                Text(
                  '* Required fields',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}