import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recruitment_task/entities/filters.dart';
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

  /// Returns a list of all products across all loaded [pages].
  List<Product> get products =>
      pages.map((page) => page.products).expand((product) => product).toList();

  /// Returns a list of products that match the applied [filters].
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
