import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/presentation/providers/search_providers.dart';
import 'package:task_calendar_app/presentation/widgets/search/highlighted_task_card.dart';
import 'package:task_calendar_app/presentation/widgets/search/search_filters.dart';
import 'package:task_calendar_app/presentation/widgets/tasks/task_card.dart';
import 'package:task_calendar_app/domain/usecases/get_tasks_by_completion_status.dart';

/// Dedicated search screen with Material 3 SearchBar and real-time search.
/// Provides comprehensive search interface following user decisions D-01, D-02, D-04, D-05.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Handle search text changes with debouncing and hybrid search logic
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text;

    // D-04: Hybrid search approach
    if (query.length >= 3) {
      // Real-time search for 3+ characters with debouncing
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(searchStateProvider.notifier).updateQuery(query);
        }
      });
    } else {
      // Clear results for queries under 3 characters per D-05
      if (mounted) {
        ref.read(searchStateProvider.notifier).clearResults();
      }
    }
  }

  /// Handle search submission for short queries
  void _onSearchSubmitted(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isNotEmpty && mounted) {
      ref.read(searchStateProvider.notifier).updateQuery(query.trim());
    }
  }

  /// Clear search and reset state
  void _clearSearch() {
    _searchController.clear();
    if (mounted) {
      ref.read(searchStateProvider.notifier).clearResults();
    }
  }

  /// Handle filter changes from SearchFilters widget
  void _onFiltersChanged({
    DateTime? startDate,
    DateTime? endDate,
    CompletionStatusFilter? statusFilter,
  }) {
    if (mounted) {
      final notifier = ref.read(searchStateProvider.notifier);
      
      // Update date filter if provided
      if (startDate != null || endDate != null) {
        notifier.updateDateFilter(startDate, endDate);
      }
      
      // Update status filter if provided
      if (statusFilter != null) {
        notifier.updateStatusFilter(statusFilter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Tasks'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search input section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search by title or description...',
              autoFocus: true, // D-02: Auto-focus keyboard
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                    tooltip: 'Clear search',
                  ),
              ],
              onSubmitted: _onSearchSubmitted,
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              elevation: WidgetStateProperty.all(0),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          
          // Search filters section
          SearchFilters(
            startDate: searchState.startDate,
            endDate: searchState.endDate,
            statusFilter: searchState.statusFilter,
            onFiltersChanged: _onFiltersChanged,
            isExpanded: true,
          ),
          
          // Results section
          Expanded(
            child: _buildResultsSection(searchState),
          ),
        ],
      ),
    );
  }

  /// Build the results section based on current search state
  Widget _buildResultsSection(SearchStateData searchState) {
    if (searchState.query.isEmpty || searchState.query.length < 3) {
      return _buildEmptyState();
    }

    if (searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (searchState.results.isEmpty) {
      return _buildNoResultsState(searchState.query);
    }

    return _buildResultsList(searchState);
  }

  /// Build empty state message per D-05
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Enter search term',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for tasks by title or description',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build no results state
  Widget _buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tasks match "$query"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get count of active filters for display
  int _getActiveFilterCount(SearchStateData searchState) {
    int count = 0;
    if (searchState.startDate != null) count++;
    if (searchState.endDate != null) count++;
    if (searchState.statusFilter != CompletionStatusFilter.all) count++;
    return count;
  }

  /// Build results list with highlighted task cards
  Widget _buildResultsList(SearchStateData searchState) {
    final activeFilterCount = _getActiveFilterCount(searchState);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header with filter count
        if (activeFilterCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '${searchState.results.length} results with $activeFilterCount active filter${activeFilterCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: searchState.results.length,
            itemBuilder: (context, index) {
              final task = searchState.results[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: HighlightedTaskCard(
                  task: task,
                  searchTerm: searchState.query,
                  key: ValueKey(task.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}