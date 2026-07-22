import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/graphql/queries.dart';
import '../models/home_models.dart';

/// Repository that fetches all data needed for the homepage.
///
/// Uses:
///   • `ThemeQueries.getThemeCustomization` → homepage section layout
///   • `CategoryQueries.getHomeCategories` → category carousel
///   • `ProductQueries.getProducts` → product carousels (Featured, Hot Deals, New, etc.)
class HomeRepository {
  final GraphQLClient _client;

  HomeRepository({required GraphQLClient client}) : _client = client;

  /// Fetches the theme customization entries that define homepage sections.
  Future<List<ThemeCustomization>> fetchThemeCustomizations() async {
    // Read the user's preferred locale for selecting the right translation
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString(LocaleCubit.localeKey) ?? 'en';

    final result = await _client.query(
      QueryOptions(
        document: gql(ThemeQueries.getThemeCustomization),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      // Some deployments can return internal errors for this resolver.
      // Degrade gracefully so the rest of the home data can still load.
      return [];
    }

    final customizationsData = result.data?['themeCustomizations'];

    final List<Map<String, dynamic>> nodes;
    if (customizationsData is List) {
      nodes = customizationsData.whereType<Map<String, dynamic>>().toList();
    } else {
      final edges = (customizationsData as Map<String, dynamic>?)?['edges']
              as List? ??
          const [];
      nodes = edges
          .map((e) => e['node'])
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return nodes
        .map(
          (node) => ThemeCustomization.fromJson(
            node,
            preferredLocale: locale,
          ),
        )
        .where((tc) => tc.status)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Fetches categories for the horizontal category carousel.
  Future<List<HomeCategory>> fetchHomeCategories() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(CategoryQueries.getHomeCategories),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      // Some deployments return warnings/errors for this resolver.
      // Keep homepage usable by returning an empty category strip.
      return [];
    }

    final categoriesData = result.data?['categories'];

    final List<Map<String, dynamic>> categoryNodes;
    if (categoriesData is List) {
      categoryNodes = categoriesData.whereType<Map<String, dynamic>>().toList();
    } else {
      final edges = (categoriesData as Map<String, dynamic>?)?['edges']
              as List? ??
          const [];
      categoryNodes = edges
          .map((e) => e['node'])
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return categoryNodes
        .map(HomeCategory.fromJson)
        .where((c) => c.numericId != 1) // exclude root category
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Fetches products with optional filter JSON and sorting.
  ///
  /// Used by product_carousel sections: Featured Products, Hot Deals,
  /// New Products, etc.
  /// Sort key options per Bagisto API: PRICE, TITLE, NEWEST, BEST_SELLING
  Future<List<HomeProduct>> fetchProducts({
    int first = 8,
    String? filter,
    String sortKey = 'NEWEST',
    bool reverse = true,
  }) async {
    final input = <Map<String, String>>[];

    void addInput(String key, dynamic value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isEmpty) return;
      input.add({'key': key, 'value': text});
    }

    addInput('limit', first);

    String? sort;
    final normalized = sortKey.toUpperCase().trim();
    if (normalized == 'PRICE') {
      sort = reverse ? 'price-desc' : 'price-asc';
    } else if (normalized == 'TITLE') {
      sort = reverse ? 'name-desc' : 'name-asc';
    } else if (normalized == 'NEWEST') {
      sort = reverse ? 'created_at-desc' : 'created_at-asc';
    }
    addInput('sort', sort);

    if (filter != null && filter.isNotEmpty) {
      try {
        final decoded = jsonDecode(filter);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            addInput(entry.key.toString(), entry.value);
          }
        }
      } catch (_) {
        addInput('filter', filter);
      }
    }

    final result = await _client.query(
      QueryOptions(
        document: gql(ProductQueries.getProducts),
        variables: {'input': input},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw Exception('Failed to load products: ${result.exception}');
    }

    final data = result.data?['products']?['data'] as List? ?? [];
    return data
      .whereType<Map<String, dynamic>>()
      .map(HomeProduct.fromJson)
        .toList();
  }
}
