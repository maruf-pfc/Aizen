import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:Aizen/features/navigation_hub/presentation/bloc/navigation_bloc.dart';
import 'package:Aizen/features/navigation_hub/presentation/bloc/navigation_event.dart';
import 'package:Aizen/features/navigation_hub/presentation/bloc/navigation_state.dart';

void main() {
  group('NavigationBloc Tests (v1.5.0)', () {
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
      'should load 2 categories with status success on LoadNavigationEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadNavigationEvent()),
      expect: () => [
        const NavigationState(status: NavigationStatus.loading),
        isA<NavigationState>()
            .having((s) => s.status, 'status', NavigationStatus.success)
            .having((s) => s.categories.length, 'categories count', 2)
            .having((s) => s.filteredCategories.length,
                'filtered categories count', 2),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'should expose 5 active modules + 4 v1.5.0 modules = 9 items total',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadNavigationEvent()),
      skip: 1,
      verify: (bloc) {
        final all = bloc.state.categories
            .expand((c) => c.items)
            .map((i) => i.id)
            .toSet();
        expect(all.length, 9);
        expect(all.contains('calculator'), true);
        expect(all.contains('expense_tracker'), true);
        expect(all.contains('clipboard_vault'), true);
        expect(all.contains('time_blocker'), true);
      },
    );

    blocTest<NavigationBloc, NavigationState>(
      'should filter items across both categories when query is set',
      build: () {
        bloc.add(const LoadNavigationEvent());
        return bloc;
      },
      skip: 2, // skip loading + success emissions from LoadNavigationEvent
      act: (bloc) => bloc.add(const SearchQueryChangedEvent('calc')),
      expect: () => [
        isA<NavigationState>()
            .having((s) => s.searchQuery, 'query', 'calc')
            .having((s) => s.filteredCategories.length,
                'matching categories', 1)
            .having((s) => s.filteredCategories.first.items.length,
                'matching items', 1), // Scientific Calculator
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'should return all categories when query cleared after a filter',
      build: () {
        bloc.add(const LoadNavigationEvent());
        return bloc;
      },
      // After LoadNavigationEvent emits loading + success (skip 2),
      // then SearchQueryChangedEvent emits 1 state,
      // then we skip 1 more to land on the empty-query reset.
      skip: 3,
      act: (bloc) {
        bloc.add(const SearchQueryChangedEvent('calc'));
        bloc.add(const SearchQueryChangedEvent(''));
      },
      expect: () => [
        isA<NavigationState>()
            .having((s) => s.searchQuery, 'query', '')
            .having((s) => s.filteredCategories.length,
                'restored categories', 2),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'should toggle isCollapsed on category toggle event (v1.5.0 group)',
      build: () {
        bloc.add(const LoadNavigationEvent());
        return bloc;
      },
      skip: 2,
      act: (bloc) =>
          bloc.add(const ToggleCategoryCollapseEvent('v1_5_modules')),
      expect: () => [
        isA<NavigationState>().having(
          (s) =>
              s.filteredCategories.firstWhere((c) => c.id == 'v1_5_modules').isCollapsed,
          'v1_5_modules isCollapsed',
          true,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'should change activeIndex on ChangeActiveIndexEvent',
      build: () {
        bloc.add(const LoadNavigationEvent());
        return bloc;
      },
      skip: 2,
      act: (bloc) => bloc.add(const ChangeActiveIndexEvent(2)),
      expect: () => [
        isA<NavigationState>().having((s) => s.activeIndex, 'activeIndex', 2),
      ],
    );
  });
}
