import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:Aizen/features/navigation_hub/presentation/bloc/navigation_bloc.dart';
import 'package:Aizen/features/navigation_hub/presentation/bloc/navigation_event.dart';
import 'package:Aizen/features/navigation_hub/presentation/bloc/navigation_state.dart';

void main() {
  group('NavigationBloc Tests', () {
    late NavigationBloc bloc;

    setUp(() {
      bloc = NavigationBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be initial status', () {
      expect(bloc.state.status, NavigationStatus.initial);
      expect(bloc.state.categories, isEmpty);
      expect(bloc.state.filteredCategories, isEmpty);
      expect(bloc.state.searchQuery, isEmpty);
    });

    blocTest<NavigationBloc, NavigationState>(
      'should load 4 categories with status success on LoadNavigationEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadNavigationEvent()),
      expect: () => [
        const NavigationState(status: NavigationStatus.loading),
        isA<NavigationState>()
            .having((s) => s.status, 'status', NavigationStatus.success)
            .having((s) => s.categories.length, 'categories count', 4)
            .having((s) => s.filteredCategories.length, 'filtered categories count', 4),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'should filter items correctly when query is set',
      build: () {
        bloc.add(const LoadNavigationEvent());
        return bloc;
      },
      skip: 2, // skip loading events
      act: (bloc) => bloc.add(const SearchQueryChangedEvent('blocker')),
      expect: () => [
        isA<NavigationState>()
            .having((s) => s.searchQuery, 'query', 'blocker')
            .having((s) => s.filteredCategories.length, 'categories matching', 1)
            .having((s) => s.filteredCategories.first.items.length, 'items matching', 2), // App Blocker, Site Blocker
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'should toggle isCollapsed on category toggle event',
      build: () {
        bloc.add(const LoadNavigationEvent());
        return bloc;
      },
      skip: 2,
      act: (bloc) => bloc.add(const ToggleCategoryCollapseEvent('focus')),
      expect: () => [
        isA<NavigationState>().having(
          (s) => s.filteredCategories.firstWhere((c) => c.id == 'focus').isCollapsed,
          'focus isCollapsed',
          true,
        ),
      ],
    );
  });
}
