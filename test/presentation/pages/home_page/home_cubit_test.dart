import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class ProductsPageMock extends Mock implements ProductsPage {}

class TagFilterMock extends Mock implements TagFilter {}

class FakeGetProductsPage extends Fake implements GetProductsPage {}

void main() {
  late HomeCubit homeCubit;
  late MockProductsRepository mockProductsRepository;

  setUpAll(() {
    registerFallbackValue(FakeGetProductsPage());
  });

  setUp(() {
    mockProductsRepository = MockProductsRepository();
    homeCubit = HomeCubit(mockProductsRepository);
  });

  tearDown(() {
    homeCubit.close();
  });

  group('HomeCubit', () {
    final tProductsPage = ProductsPageMock();
    final tFilters = [TagFilterMock()];

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Loaded] when getNextPage is successful',
      build: () {
        when(() => mockProductsRepository.getProductsPage(any()))
            .thenAnswer((_) async => tProductsPage);
        return homeCubit;
      },
      act: (cubit) => cubit.getNextPage(),
      expect: () => [
        const Loading(),
        Loaded(pages: [tProductsPage]),
      ],
    );

    final exception = Exception('Failed to load');

    blocTest<HomeCubit, HomeState>(
      'emits [Loading, Error] when getNextPage throws an exception',
      build: () {
        when(() => mockProductsRepository.getProductsPage(any()))
            .thenThrow(exception);
        return homeCubit;
      },
      act: (cubit) => cubit.getNextPage(),
      expect: () => [
        const Loading(),
        Error(error: exception),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [Loaded] with filters when setProductFilters is called',
      build: () => homeCubit,
      act: (cubit) => cubit.setProductFilters(filters: tFilters),
      expect: () => [
        Loaded(pages: const [], filters: tFilters),
      ],
    );

    final tFirstPage = ProductsPageMock();
    final tLastPage = ProductsPageMock();

    blocTest<HomeCubit, HomeState>(
      "Does not fetch any new pages if it gets to the last one (doesn't call _productsRepository.getProductsPage)",
      build: () {
        when(() => tFirstPage.totalPages).thenAnswer((_) => 2);
        when(() => tLastPage.totalPages).thenAnswer((_) => 2);
        when(() => mockProductsRepository.getProductsPage(any()))
            .thenAnswer((invocation) async {
          final param = invocation.positionalArguments.first as GetProductsPage;
          if (param.pageNumber == 1) {
            return tFirstPage;
          } else if (param.pageNumber == 2) {
            return tLastPage;
          }
          throw Exception('No more pages');
        });

        return homeCubit;
      },
      act: (cubit) async {
        await cubit.getNextPage();
        await cubit.getNextPage();
        await cubit.getNextPage();
      },
      expect: () => [
        const Loading(),
        Loaded(pages: [tFirstPage, tLastPage]),
        const Loading(),
        Loaded(pages: [tFirstPage, tLastPage]),
        const Loading(),
        Loaded(pages: [tFirstPage, tLastPage]),
      ],
      verify: (_) {
        // Verify that the repository was called exactly twice
        verify(() => mockProductsRepository.getProductsPage(any())).called(2);

        expect(homeCubit.canFetchMorePages, false);
      },
    );
  });
}
