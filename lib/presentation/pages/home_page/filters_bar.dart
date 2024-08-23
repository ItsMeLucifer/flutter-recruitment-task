import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/entities/filters.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/bordered_button.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/price_filter_dialog.dart';
import 'package:flutter_recruitment_task/utils/build_context2.dart';
import 'package:flutter_recruitment_task/utils/iterable2.dart';

class FiltersBar extends StatelessWidget {
  final Loaded state;
  const FiltersBar({
    required this.state,
    super.key,
  });

  static const double height = 50;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _TagFilterButton(state: state),
            const VerticalDivider(),
            _FavoriteFilterButton(state: state),
            const VerticalDivider(),
            _PriceFilterButton(state: state),
          ],
        ),
      ),
    );
  }
}

class _TagFilterButton extends StatelessWidget {
  final Loaded state;
  const _TagFilterButton({required this.state});

  List<Tag> get tags {
    final products =
        state.pages.map((page) => page.products).expand((products) => products);
    final tags = products.map((product) => product.tags).expand((tags) => tags);
    // Remove duplicates and return a list
    return tags.toSet().toList();
  }

  TagFilter? get currentTagFilter =>
      state.filters.whereType<TagFilter>().firstOrNull;

  @override
  Widget build(BuildContext context) {
    return BorderedButton(
      height: FiltersBar.height,
      child: DropdownButton(
        hint: SizedBox(
          width: context.width(0.4),
          child: Text(
            currentTagFilter?.tags
                    .map((t) => t.label)
                    .reduceOrNull((first, next) => '$first, $next') ??
                'Filter by tags',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        items: tags
            .map(
              (t) => DropdownMenuItem(
                value: t,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentTagFilter?.tags.contains(t) ?? false) ...[
                      const Icon(Icons.check),
                    ],
                    Text(
                      t.label,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (tag) {
          if (tag == null) return;
          final List<Tag> currentTags = currentTagFilter?.tags ?? [];

          if (currentTags.contains(tag)) {
            currentTags.remove(tag);
          } else {
            currentTags.add(tag);
          }
          final TagFilter newTagFilter = TagFilter(tags: currentTags);

          List<Filter> newFilters = [...state.filters];

          // Remove current TagFilter
          if (currentTagFilter != null) {
            final tagFilterIndex = state.filters.indexOf(currentTagFilter!);
            newFilters.removeAt(tagFilterIndex);
          }
          // Add new TagFilter
          if (newTagFilter.tags.isNotEmpty) {
            newFilters.add(newTagFilter);
          }
          context.read<HomeCubit>().setProductFilters(filters: newFilters);
        },
      ),
    );
  }
}

class _FavoriteFilterButton extends StatelessWidget {
  final Loaded state;
  const _FavoriteFilterButton({required this.state});

  bool get filteredByFavorite =>
      state.filters.whereType<FavoriteFilter>().isNotEmpty;

  void setFilter(BuildContext context, {required bool favoriteOnly}) {
    final List<Filter> newFilters = [...state.filters];

    if (favoriteOnly) {
      newFilters.add(const FavoriteFilter());
    } else {
      newFilters.remove(state.filters.whereType<FavoriteFilter>().first);
    }

    context.read<HomeCubit>().setProductFilters(filters: newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return BorderedButton(
      height: FiltersBar.height,
      onTap: () => setFilter(context, favoriteOnly: !filteredByFavorite),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox.adaptive(
            value: filteredByFavorite,
            onChanged: (value) {
              if (value == null) return;
              setFilter(context, favoriteOnly: value);
            },
          ),
          const Text('Favorites only'),
        ],
      ),
    );
  }
}

class _PriceFilterButton extends StatelessWidget {
  final Loaded state;
  const _PriceFilterButton({required this.state});

  @override
  Widget build(BuildContext context) {
    return BorderedButton(
      onTap: () => PriceFilterDialog(
        state: state,
        setProductFilters: context.read<HomeCubit>().setProductFilters,
      ).show(context),
      height: FiltersBar.height,
      child: const Text('Filter by price'),
    );
  }
}
