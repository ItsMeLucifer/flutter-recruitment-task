import 'package:flutter_recruitment_task/models/products_page.dart';

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
