import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:flutter_recruitment_task/presentation/widgets/filters_bar.dart';

const _mainPadding = EdgeInsets.all(16.0);

class HomePage extends StatelessWidget {
  /// The ID of the product to be scrolled, if not found on the current products
  /// page, the widget will try to download the next page.
  final int? highlighedProductId;

  const HomePage({
    this.highlighedProductId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BigText('Products'),
      ),
      body: Padding(
        padding: _mainPadding,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              Error() => BigText('Error: ${state.error}'),
              Loading() => const BigText('Loading...'),
              Loaded() => _LoadedWidget(
                  state: state,
                  highlightedProductId: highlighedProductId,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedWidget extends StatefulWidget {
  final Loaded state;
  final int? highlightedProductId;

  const _LoadedWidget({
    this.highlightedProductId,
    required this.state,
  });

  @override
  State<_LoadedWidget> createState() => _LoadedWidgetState();
}

class _LoadedWidgetState extends State<_LoadedWidget> {
  late final ScrollController controller;

  late final List<Product> products;

  @override
  void initState() {
    controller = ScrollController();
    products = widget.state.pages
        .map((page) => page.products)
        .expand((product) => product)
        .toList();
    // Scroll to highlighted product
    if (widget.highlightedProductId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _highlightProduct());
    }
    super.initState();
  }

  List<Product> get filteredProducts => products.where((product) {
        return widget.state.filters.isEmpty ||
            widget.state.filters.every((filter) => filter.accepts(product));
      }).toList();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FiltersBar(state: widget.state),
        Expanded(
          child: CustomScrollView(
            controller: controller,
            shrinkWrap: true,
            slivers: [
              _ProductsSliverList(products: filteredProducts),
              if (context.read<HomeCubit>().canFetchMorePages)
                const _GetNextPageButton(),
            ],
          ),
        ),
      ],
    );
  }

  void _highlightProduct() {
    final product =
        products.firstWhereOrNull((p) => p.id == widget.highlightedProductId!);
    if (product == null) {
      context.read<HomeCubit>().getNextPage();
      return;
    }
    final productIndex = products.indexOf(product);
    final offset = _calculateOffset(productIndex);
    const Duration animationDuration = Duration(seconds: 1);

    controller.animateTo(
      offset,
      duration: animationDuration,
      curve: Curves.easeInOut,
    );
  }

  double _calculateOffset(int itemIndex) {
    return itemIndex *
        (_ProductCard.height + _ProductsSliverList.dividerHeight);
  }
}

class _ProductsSliverList extends StatelessWidget {
  final List<Product> products;
  const _ProductsSliverList({required this.products});

  static const double dividerHeight = 16;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductCard(
        products[index],
        key: Key('product_$index'),
      ),
      separatorBuilder: (context, index) =>
          const Divider(height: dividerHeight),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
    this.product, {
    super.key,
  });

  final Product product;

  static const double height = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BigText(product.name),
            Expanded(child: _Tags(product: product)),
          ],
        ),
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: product.tags.map(_TagWidget.new).toList(),
    );
  }
}

class _TagWidget extends StatefulWidget {
  const _TagWidget(this.tag);

  final Tag tag;

  @override
  State<_TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<_TagWidget> {
  List<MaterialColor> get possibleColors => Colors.primaries;

  late final Color color;

  @override
  void initState() {
    color = possibleColors[Random().nextInt(possibleColors.length)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        color: MaterialStateProperty.all(color),
        label: Text(widget.tag.label),
      ),
    );
  }
}

class _GetNextPageButton extends StatelessWidget {
  const _GetNextPageButton();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: TextButton(
        onPressed: context.read<HomeCubit>().getNextPage,
        child: const BigText('Get next page'),
      ),
    );
  }
}
