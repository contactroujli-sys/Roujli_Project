class SuggestionItem {
  final String id;
  final String title;
  final String type; // 'business', 'category', 'product', 'service'
  final String? subtitle;
  final String? logo;
  final String? businessId;
  final double? price;

  const SuggestionItem({
    required this.id,
    required this.title,
    required this.type,
    this.subtitle,
    this.logo,
    this.businessId,
    this.price,
  });
}

class SearchSuggestionResult {
  final List<SuggestionItem> businesses;
  final List<SuggestionItem> categories;
  final List<SuggestionItem> products;
  final List<SuggestionItem> services;

  const SearchSuggestionResult({
    this.businesses = const [],
    this.categories = const [],
    this.products = const [],
    this.services = const [],
  });

  bool get isEmpty => businesses.isEmpty && categories.isEmpty && products.isEmpty && services.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
