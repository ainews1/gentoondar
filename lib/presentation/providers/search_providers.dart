import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:task_calendar_app/core/error/failures.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/domain/usecases/search_tasks.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';

// =============================================================================
// Search Use Case Provider
// =============================================================================

/// Provides SearchTasks use case
final searchTasksUseCaseProvider = Provider<SearchTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return SearchTasks(repository);
});

// =============================================================================
// Search State Data Model
// =============================================================================

/// Data model for search state containing query, results, and loading state
class SearchStateData {
  final String query;
  final List<Task> results;
  final bool isLoading;
  final Failure? error;

  const SearchStateData({
    required this.query,
    required this.results,
    required this.isLoading,
    this.error,
  });

  SearchStateData copyWith({
    String? query,
    List<Task>? results,
    bool? isLoading,
    Failure? error,
  }) {
    return SearchStateData(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Check if search state is empty (no query or results)
  bool get isEmpty => query.isEmpty && results.isEmpty;

  /// Check if search has active query
  bool get hasQuery => query.isNotEmpty;

  /// Check if search has results
  bool get hasResults => results.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchStateData &&
        other.query == query &&
        other.results == results &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return query.hashCode ^
        results.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }
}

// =============================================================================
// Search State Management
// =============================================================================

/// StateNotifier for managing comprehensive search state with debouncing
class SearchStateNotifier extends StateNotifier<SearchStateData> {
  SearchStateNotifier(this.ref) : super(const SearchStateData(
    query: '',
    results: [],
    isLoading: false,
  ));

  final Ref ref;
  Timer? _debounceTimer;

  /// Update search query with debouncing and hybrid search logic per D-04
  void updateQuery(String newQuery) {
    // Cancel any pending debounced search
    _debounceTimer?.cancel();

    // Update query immediately
    state = state.copyWith(
      query: newQuery,
      error: null,
    );

    // Clear results for queries under 3 characters per D-05
    if (newQuery.trim().length < 3) {
      state = state.copyWith(
        results: [],
        isLoading: false,
      );
      return;
    }

    // Start loading state
    state = state.copyWith(isLoading: true);

    // Debounce search execution (300ms)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(newQuery.trim());
    });
  }

  /// Clear search results and query
  void clearResults() {
    _debounceTimer?.cancel();
    state = const SearchStateData(
      query: '',
      results: [],
      isLoading: false,
    );
  }

  /// Perform the actual search operation
  Future<void> _performSearch(String searchTerm) async {
    if (searchTerm.isEmpty) {
      state = state.copyWith(
        results: [],
        isLoading: false,
      );
      return;
    }

    final useCase = ref.read(searchTasksUseCaseProvider);
    final result = await useCase(SearchTasksParams(searchTerm: searchTerm));

    // Only update if this search is still current
    if (state.query.trim() == searchTerm) {
      state = result.fold(
        (failure) => state.copyWith(
          isLoading: false,
          error: failure,
          results: [],
        ),
        (tasks) => state.copyWith(
          isLoading: false,
          error: null,
          results: tasks, // Results already ordered by most recent first per D-07
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// StateNotifierProvider for search state management
final searchStateProvider = StateNotifierProvider<SearchStateNotifier, SearchStateData>((ref) {
  return SearchStateNotifier(ref);
});

// =============================================================================
// Convenience Providers
// =============================================================================

/// Provider for current search query
final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(searchStateProvider).query;
});

/// Provider for search results
final searchResultsProvider = Provider<List<Task>>((ref) {
  return ref.watch(searchStateProvider).results;
});

/// Provider for search loading state
final searchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(searchStateProvider).isLoading;
});

/// Provider for search error state
final searchErrorProvider = Provider<Failure?>((ref) {
  return ref.watch(searchStateProvider).error;
});

/// Provider to check if search has active query (3+ characters)
final hasActiveSearchProvider = Provider<bool>((ref) {
  final query = ref.watch(searchQueryProvider);
  return query.trim().length >= 3;
});

/// Provider to check if search has results
final hasSearchResultsProvider = Provider<bool>((ref) {
  final results = ref.watch(searchResultsProvider);
  return results.isNotEmpty;
});

// =============================================================================
// FutureProvider Alternative (for reference, not used in hybrid search)
// =============================================================================

/// Alternative FutureProvider for search (not used in main implementation)
/// Kept for reference in case direct search calls are needed elsewhere
final searchTasksProvider = FutureProvider.family<List<Task>, String>((ref, searchTerm) async {
  if (searchTerm.trim().isEmpty) {
    return [];
  }

  final useCase = ref.watch(searchTasksUseCaseProvider);
  final result = await useCase(SearchTasksParams(searchTerm: searchTerm.trim()));
  
  return result.fold(
    (failure) => <Task>[], // Return empty list on failure
    (tasks) => tasks,
  );
});