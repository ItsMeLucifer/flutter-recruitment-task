import 'package:bloc/bloc.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

/// States
sealed class HomeState {
  const HomeState();
}

class Loading extends HomeState {
  const Loading();
}

class Loaded extends HomeState {
  const Loaded({
    required this.pages,
    this.filters = const <Filter>[],
  });

  final List<ProductsPage> pages;
  final List<Filter> filters;
}

class Error extends HomeState {
  const Error({required this.error});

  final dynamic error;
}

/// Cubit

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = GetProductsPage(pageNumber: 1);

  bool get canFetchMorePages {
    final totalPages = _pages.lastOrNull?.totalPages;
    if (totalPages != null && _param.pageNumber > totalPages) {
      return false;
    }
    return true;
  }

  Future<void> getNextPage() async {
    emit(const Loading());
    try {
      if (!canFetchMorePages) {
        return emit(Loaded(pages: _pages));
      }
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);
      emit(Loaded(pages: _pages));
    } catch (e) {
      emit(Error(error: e));
    }
  }
}

/// Filters

sealed class Filter {
  const Filter();
}

class TagFilter extends Filter {
  const TagFilter({required this.tags});

  final List<Tag> tags;
}

class FavoriteFilter extends Filter {
  const FavoriteFilter();
}

class PriceFilter extends Filter {
  const PriceFilter({
    this.min,
    this.max,
  }) : assert(min != null || max != null,
            'At least one of the values ([min] or [max]) must be provided.');

  final double? min;
  final double? max;
}
