import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

/// States
sealed class HomeState extends Equatable {
  const HomeState();
}

class Loading extends HomeState {
  const Loading();

  @override
  List<Object> get props => [];
}

class Loaded extends HomeState {
  const Loaded({
    required this.pages,
    this.filters = const <Filter>[],
  });

  final List<ProductsPage> pages;
  final List<Filter> filters;

  // Getters

  List<Product> get products =>
      pages.map((page) => page.products).expand((product) => product).toList();

  List<Product> get filteredProducts => products
      .where((product) =>
          filters.isEmpty ||
          filters.every(
            (filter) => filter.accepts(product),
          ))
      .toList();

  @override
  List<Object> get props => [pages, filters];
}

class Error extends HomeState {
  const Error({required this.error});

  final dynamic error;

  @override
  List<Object> get props => [error];
}

/// Cubit

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = const GetProductsPage(pageNumber: 1);

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
    } catch (e, stack) {
      debugPrint('$e\n$stack');
      emit(Error(error: e));
    }
  }

  void setProductFilters({
    required List<Filter> filters,
  }) {
    emit(Loaded(pages: _pages, filters: filters));
  }
}

/// Filters

sealed class Filter {
  const Filter();

  bool accepts(Product product);
}

class TagFilter extends Filter {
  const TagFilter({required this.tags});

  final List<Tag> tags;

  @override
  bool accepts(Product product) {
    if (product.tags.isEmpty && tags.isNotEmpty) return false;
    return tags.every((tag) => product.tags.contains(tag));
  }
}

class FavoriteFilter extends Filter {
  const FavoriteFilter();

  @override
  bool accepts(Product product) {
    return product.isFavorite ?? false;
  }
}

class PriceFilter extends Filter {
  const PriceFilter({
    this.min,
    this.max,
  }) : assert(min != null || max != null,
            'At least one of the values ([min] or [max]) must be provided.');

  final double? min;
  final double? max;

  @override
  bool accepts(Product product) {
    final regularPrice = product.offer.regularPrice.amount;

    bool result = true;
    if (max != null && regularPrice > max!) {
      result = false;
    }
    return result && regularPrice > (min ?? 0);
  }
}
