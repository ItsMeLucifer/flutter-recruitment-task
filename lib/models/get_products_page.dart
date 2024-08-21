class GetProductsPage {
  GetProductsPage({
    required this.pageNumber,
  });

  final int pageNumber;

  GetProductsPage copyWith({
    int? pageNumber,
  }) =>
      GetProductsPage(pageNumber: pageNumber ?? this.pageNumber);

  GetProductsPage increasePageNumber() {
    return GetProductsPage(pageNumber: pageNumber + 1);
  }
}
