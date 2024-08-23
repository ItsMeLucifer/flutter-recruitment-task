import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

part 'products_page.g.dart';

@JsonSerializable()
class ProductsPage {
  ProductsPage({
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.products,
  });

  factory ProductsPage.fromJson(Map<String, dynamic> json) =>
      _$ProductsPageFromJson(json);

  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final List<Product> products;
}

@JsonSerializable()
class Product {
  Product({
    required this.id,
    required this.name,
    required this.mainImage,
    required this.description,
    required this.available,
    required this.isFavorite,
    required this.isBlurred,
    required this.sellerId,
    required this.tags,
    required this.offer,
  });

  /// Integers work better as an ID field (space saving and performance reasons).
  /// Since the id field is actually an integer converted to String,
  /// I decided to modify the parsing from json.
  /// (The best solution would be to change the hierarchy of the project,
  /// adding entities, so that we would separate what is fetched from
  /// the server (or file) from what we are working on in the application -
  /// in this case the model could have an id field of String type, and
  /// the entity an id field of integer type. This allows you to separate the data layer from the domain layer.
  /// However, I decided not to do this, as it would affect the [ProductsRepository] file,
  /// the modification of which has been prohibited)
  factory Product.fromJson(Map<String, dynamic> json) {
    json['id'] = int.parse(json['id']);
    return _$ProductFromJson(json);
  }

  final int id;
  final String name;
  final String mainImage;
  final String description;
  final bool available;
  final bool? isFavorite;
  final bool? isBlurred;
  final String sellerId;
  final List<Tag> tags;
  final Offer offer;
}

@JsonSerializable()
class Offer {
  Offer({
    required this.skuId,
    required this.sellerId,
    required this.sellerName,
    required this.subtitle,
    required this.isSponsored,
    required this.isBest,
    required this.regularPrice,
    required this.promotionalPrice,
    required this.normalizedPrice,
    required this.promotionalNormalizedPrice,
    required this.omnibusPrice,
    required this.omnibusLabel,
    required this.tags,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  final String skuId;
  final String sellerId;
  final String sellerName;
  final String subtitle;
  final bool? isSponsored;
  final bool? isBest;
  final Price regularPrice;
  final Price? promotionalPrice;
  final NormalizedPrice? normalizedPrice;
  final NormalizedPrice? promotionalNormalizedPrice;
  final Price? omnibusPrice;
  final String? omnibusLabel;
  final List<Tag>? tags;
}

@JsonSerializable()
class Tag extends Equatable {
  Tag({
    required this.tag,
    required this.label,
    required this.color,
    required this.labelColor,
  }) {
    // When scrolling the list in [HomePage], SliverList.separated disposes of items
    // that do not display on the screen to optimize memory.
    // There are many ways to solve the problem:
    //   - Store in HomeCubit (e.g. in the map) information about the color
    //   assigned to the tag when the widget is initialized (it would
    //   contain such information as productId, tag, and assigned color)
    //   - Make use of the `color` field available in the Tag model
    //   - Create a new field in the Tag class and assign a random color to it in the constructor

    // I decided to use the last option. It seemed the simplest as well as the most optimal.
    // Probably a better solution would have been to create a Tag entity (and, for example,
    // rename *this* class to TagModel) that would not be immutable, so that the model
    // would not hold data strictly related to the presentation layer, but that would
    // have required a change in the architecture, which seems as a too radical change.
    const possibleColors = Colors.primaries;
    initialRandomColor =
        possibleColors[Random().nextInt(possibleColors.length)];
  }

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  final String tag;
  final String label;
  final String color;
  final String labelColor;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final Color initialRandomColor;

  @override
  List<Object> get props => [tag];
}

@JsonSerializable()
class Price {
  Price({
    required this.amount,
    required this.currency,
  });

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

  final double amount;
  final String currency;
}

@JsonSerializable()
class NormalizedPrice {
  NormalizedPrice({
    required this.amount,
    required this.currency,
    required this.unitLabel,
  });

  factory NormalizedPrice.fromJson(Map<String, dynamic> json) =>
      _$NormalizedPriceFromJson(json);

  final double amount;
  final String currency;
  final String? unitLabel;
}
