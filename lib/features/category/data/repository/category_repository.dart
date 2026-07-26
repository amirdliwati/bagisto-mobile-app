import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:convert';
import '../../../../core/graphql/queries.dart';
import '../models/category_model.dart';
import '../models/filter_model.dart';
import '../models/product_model.dart';

class CategoryRepository {
  final GraphQLClient client;

  CategoryRepository({required this.client});

  /// Fetch tree categories (hierarchical)
  /// Maps to: GET_TREE_CATEGORIES from nextjs-commerce
  Future<List<CategoryModel>> getTreeCategories({int? parentId}) async {
    final result = await client.query(
      QueryOptions(
        document: gql(CategoryQueries.getTreeCategories),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['treeCategories'] as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((json) => CategoryModel.fromTreeJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch flat home categories
  /// Maps to: GET_HOME_CATEGORIES from nextjs-commerce
  Future<List<CategoryModel>> getHomeCategories() async {
    final result = await client.query(
      QueryOptions(
        document: gql(CategoryQueries.getHomeCategories),
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final categoriesData = result.data?['categories'];

    if (categoriesData is List) {
      return categoriesData
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromHomeCategoryJson)
          .toList();
    }

    final edges =
        (categoriesData as Map<String, dynamic>?)?['edges'] as List<dynamic>? ??
        [];

    return edges
        .map(
          (edge) => CategoryModel.fromHomeCategoryJson(
            edge['node'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Fetch products with pagination & filters
  /// Maps to: GET_PRODUCTS from nextjs-commerce
  Future<PaginatedProducts> getProducts({
    String? query,
    String? sortKey,
    bool? reverse,
    int? first,
    int? last,
    String? after,
    String? before,
    String? channel,
    String? locale,
    String? filter,
  }) async {
    final variables = {
      'input': _buildProductsInput(
        query: query,
        sortKey: sortKey,
        reverse: reverse,
        first: first,
        last: last,
        after: after,
        before: before,
        channel: channel,
        locale: locale,
        filter: filter,
      ),
    };

    final result = await client.query(
      QueryOptions(
        document: gql(ProductQueries.getProducts),
        variables: variables,
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return PaginatedProducts.fromJson(result.data!);
  }

  /// Fetch products filtered by category
  /// Maps to: GET_FILTER_PRODUCTS from nextjs-commerce
  /// [useCacheFirst] - if true, returns cached data immediately without network request
  ///                 (use for initial display, then call again with false for fresh data)
  Future<PaginatedProducts> getFilterProducts({
    required String filter,
    String? sortKey,
    bool? reverse,
    int? first,
    int? last,
    String? after,
    String? before,
    bool useCacheFirst = false,
  }) async {
    final variables = {
      'input': _buildProductsInput(
        filter: filter,
        sortKey: sortKey,
        reverse: reverse,
        first: first,
        last: last,
        after: after,
        before: before,
      ),
    };

    debugPrint(
      '[CategoryRepo] getFilterProducts variables=$variables, useCacheFirst=$useCacheFirst',
    );

    final result = await client.query(
      QueryOptions(
        document: gql(ProductQueries.getFilterProducts),
        variables: variables,
        fetchPolicy: useCacheFirst
            ? FetchPolicy.cacheFirst
            : FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      debugPrint('[CategoryRepo] getFilterProducts error: ${result.exception}');
      throw result.exception!;
    }

    debugPrint(
      '[CategoryRepo] getFilterProducts totalCount=${result.data?['products']?['paginatorInfo']?['total']}',
    );
    return PaginatedProducts.fromJson(result.data!);
  }

  List<Map<String, String>> _buildProductsInput({
    String? query,
    String? sortKey,
    bool? reverse,
    int? first,
    int? last,
    String? after,
    String? before,
    String? channel,
    String? locale,
    String? filter,
  }) {
    final input = <Map<String, String>>[];

    void addInput(String key, dynamic value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isEmpty) return;
      input.add({'key': key, 'value': text});
    }

    // Query term.
    addInput('query', query);

    // Pagination: API is page/limit based.
    final limit = first ?? last;
    addInput('limit', limit ?? 10);

    int page = 1;
    final rawCursor = after ?? before;
    if (rawCursor != null && rawCursor.isNotEmpty) {
      page = int.tryParse(rawCursor) ?? 1;
    }
    if (page < 1) page = 1;
    addInput('page', page);

    // Sorting.
    final sort = _mapSort(sortKey, reverse);
    if (sort != null) {
      addInput('sort', sort);
    }

    // Optional channel/locale, if provided by callers.
    addInput('channel', channel);
    addInput('locale', locale);

    // Merge JSON filter map to input key/value pairs.
    if (filter != null && filter.isNotEmpty) {
      try {
        final decoded = jsonDecode(filter);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            addInput(entry.key.toString(), entry.value);
          }
        }
      } catch (_) {
        // If the filter is not JSON, pass it through for compatibility.
        addInput('filter', filter);
      }
    }

    return input;
  }

  String? _mapSort(String? sortKey, bool? reverse) {
    if (sortKey == null || sortKey.isEmpty) return null;

    final normalized = sortKey.toUpperCase().trim();
    final desc = reverse == true;

    switch (normalized) {
      case 'PRICE':
        return desc ? 'price-desc' : 'price-asc';
      case 'TITLE':
        return desc ? 'name-desc' : 'name-asc';
      case 'NEWEST':
        return desc ? 'created_at-desc' : 'created_at-asc';
      case 'BEST_SELLING':
        return desc ? 'best_selling-desc' : 'best_selling-asc';
      default:
        return null;
    }
  }

  /// Fetch single product by URL key
  /// Maps to: GET_PRODUCT_BY_URL_KEY from nextjs-commerce
  Future<ProductModel> getProductByUrlKey(
    String urlKey, {
    String? productType,
  }) async {
    final normalizedType = (productType ?? '').toLowerCase().trim();
    if (normalizedType == 'booking') {
      final bookingType = await _resolveBookingTypeByUrlKey(urlKey);
      final query = ProductQueries.getBookingProductByUrlKeyForType(
        bookingType,
      );

      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'urlKey': urlKey},
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final productData = result.data?['product'] ?? (result.data?['products']?['data'] as List?)?.firstOrNull;
      if (productData == null) {
        throw Exception('Product not found: $urlKey');
      }

      final product = ProductModel.fromJson(
        productData as Map<String, dynamic>,
      );
      _logBookingAvailability(product, source: 'urlKey:$urlKey');
      return product;
    }

    final query = ProductQueries.getProductByUrlKeyByType(productType);

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'urlKey': urlKey},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final productData = result.data?['product'] ?? (result.data?['products']?['data'] as List?)?.firstOrNull;
    if (productData == null) {
      throw Exception('Product not found: $urlKey');
    }

    final product = ProductModel.fromJson(
      productData as Map<String, dynamic>,
    );
    _logBookingAvailability(product, source: 'urlKey:$urlKey');
    return product;
  }

  /// Fetch single product by ID
  /// Maps to: GET_PRODUCT_BY_ID from nextjs-commerce
  Future<ProductModel> getProductById(
    String productId, {
    String? productType,
  }) async {
    final normalizedType = (productType ?? '').toLowerCase().trim();
    if (normalizedType == 'booking') {
      final bookingType = await _resolveBookingTypeById(productId);
      final query = ProductQueries.getBookingProductByIdForType(bookingType);

      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'id': productId},
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final productData = result.data?['product'] ?? (result.data?['products']?['data'] as List?)?.firstOrNull;
      if (productData == null) {
        throw Exception('Product not found: $productId');
      }

      final product = ProductModel.fromJson(
        productData as Map<String, dynamic>,
      );
      _logBookingAvailability(product, source: 'id:$productId');
      return product;
    }

    final query = ProductQueries.getProductById;

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'id': productId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final productData = result.data?['product'] ?? (result.data?['products']?['data'] as List?)?.firstOrNull;
    if (productData == null) {
      throw Exception('Product not found: $productId');
    }

    final product = ProductModel.fromJson(
      productData as Map<String, dynamic>,
    );
    _logBookingAvailability(product, source: 'id:$productId');
    return product;
  }

  Future<List<BookingSlotOption>> getBookingSlots({
    required BookingProductData booking,
    required String date,
    String? rentingType,
  }) async {
    final type = (booking.type ?? '').toLowerCase().trim();
    final normalizedRentingType = (rentingType ?? '').toLowerCase().trim();
    final bookingId = _resolveBookingSlotId(booking);

    if (bookingId <= 0) {
      throw Exception('Missing booking slot id for $type product');
    }

    final isRentalHourly =
        type == 'rental' && normalizedRentingType == 'hourly';
    final result = await client.query(
      QueryOptions(
        document: gql(
          isRentalHourly
              ? ProductQueries.getBookingRentalHourlySlots
              : ProductQueries.getBookingSlots,
        ),
        variables: {'id': bookingId, 'date': date},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final slots = result.data?['bookingSlots'] as List<dynamic>? ?? const [];

    if (isRentalHourly) {
      return slots
          .whereType<Map<String, dynamic>>()
          .expand(BookingSlotOption.fromRentalSummaryJson)
          .where((slot) => slot.label.trim().isNotEmpty)
          .toList();
    }

    return slots
        .whereType<Map<String, dynamic>>()
        .map(BookingSlotOption.fromStandardJson)
        .where((slot) => slot.label.trim().isNotEmpty)
        .toList();
  }

  Future<String> _resolveBookingTypeByUrlKey(String urlKey) async {
    final result = await client.query(
      QueryOptions(
        document: gql(ProductQueries.getBookingProductTypeByUrlKey),
        variables: {'urlKey': urlKey},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final product = result.data?['product'] ?? (result.data?['products']?['data'] as List?)?.firstOrNull;
    final edges = product?['bookingProducts']?['edges'] as List<dynamic>? ?? [];
    if (edges.isEmpty) return 'default';

    final node = edges.first['node'] as Map<String, dynamic>?;
    final bookingType = node?['type']?.toString().trim();
    if (bookingType == null || bookingType.isEmpty) return 'default';
    return bookingType;
  }

  Future<String> _resolveBookingTypeById(String productId) async {
    final result = await client.query(
      QueryOptions(
        document: gql(ProductQueries.getBookingProductTypeById),
        variables: {'id': productId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final product = result.data?['product'] ?? (result.data?['products']?['data'] as List?)?.firstOrNull;
    final edges = product?['bookingProducts']?['edges'] as List<dynamic>? ?? [];
    if (edges.isEmpty) return 'default';

    final node = edges.first['node'] as Map<String, dynamic>?;
    final bookingType = node?['type']?.toString().trim();
    if (bookingType == null || bookingType.isEmpty) return 'default';
    return bookingType;
  }

  int _resolveBookingSlotId(BookingProductData booking) {
    final type = (booking.type ?? '').toLowerCase().trim();

    switch (type) {
      case 'appointment':
      case 'rental':
      case 'table':
        return booking.activeSlot?.resolvedBookingId ?? 0;
      case 'default':
      default:
        return booking.numericId ?? int.tryParse(booking.id) ?? 0;
    }
  }

  void _logBookingAvailability(ProductModel product, {required String source}) {
    if (!product.isBooking || product.bookingProducts.isEmpty) return;

    for (final booking in product.bookingProducts) {
      debugPrint(
        '[CategoryRepo] booking availability ($source) '
        'type=${booking.type} '
        'availableFrom=${booking.availableFrom} '
        'availableTo=${booking.availableTo}',
      );
    }
  }

  /// Fetch filter attribute options (legacy – single attribute by ID)
  /// Maps to: GET_FILTER_OPTIONS from nextjs-commerce
  /// Attribute IDs: color=/api/admin/attributes/23, size=24, brand=25
  Future<FilterAttribute?> getFilterOptions({
    required String attributeId,
    String locale = 'en',
  }) async {
    final result = await client.query(
      QueryOptions(
        document: gql(FilterQueries.getFilterOptions),
        variables: {'id': attributeId},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['attribute'] as Map<String, dynamic>?;
    if (data == null) return null;

    return FilterAttribute.fromJson(data);
  }

  /// Fetch all filterable attributes for a category dynamically.
  ///
  /// Uses the `categoryAttributeFilters` GraphQL query.
  /// [categorySlug] – the category slug (or empty string for all).
  /// Returns a list of [FilterAttribute] with options, price range, etc.
  Future<List<FilterAttribute>> getCategoryAttributeFilters({
    String categorySlug = '',
    int first = 50,
  }) async {
    debugPrint(
      '[CategoryRepo] getCategoryAttributeFilters slug="$categorySlug", first=$first',
    );

    final result = await client.query(
      QueryOptions(
        document: gql(FilterQueries.getCategoryAttributeFilters),
        variables: {'categorySlug': categorySlug},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      debugPrint(
        '[CategoryRepo] getCategoryAttributeFilters error: ${result.exception}',
      );
      throw result.exception!;
    }

    final getFilterAttributeData = result.data?['getFilterAttribute'];
    if (getFilterAttributeData == null) {
      return [];
    }

    final double? minPrice = _parseDouble(getFilterAttributeData['minPrice']);
    final double? maxPrice = _parseDouble(getFilterAttributeData['maxPrice']);
    
    final rawAttributes = getFilterAttributeData['filterAttributes'] as List<dynamic>? ?? [];

    final attributes = rawAttributes.map((node) {
      return FilterAttribute.fromCategoryFilterJson(node as Map<String, dynamic>);
    }).toList();

    // Sort by position
    attributes.sort((a, b) => (a.position ?? 999).compareTo(b.position ?? 999));

    // If minPrice and maxPrice are available, add a price filter at the beginning
    if (minPrice != null && maxPrice != null) {
      attributes.insert(
        0,
        FilterAttribute(
          id: 'price',
          code: 'price',
          adminName: 'Price',
          type: 'price',
          minPrice: minPrice,
          maxPrice: maxPrice,
          isFilterable: true,
        ),
      );
    }

    debugPrint(
      '[CategoryRepo] getCategoryAttributeFilters loaded ${attributes.length} attributes: '
      '${attributes.map((a) => "${a.code}(${a.options.length} opts, price=${a.isPriceFilter})").join(", ")}',
    );

    return attributes;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Fetch related products for a given product
  Future<List<ProductModel>> getRelatedProducts(
    String urlKey, {
    int first = 10,
  }) async {
    final result = await client.query(
      QueryOptions(
        document: gql(ProductQueries.getRelatedProducts),
        variables: {'urlKey': urlKey, 'first': first},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final productData = result.data?['product'] ?? (result.data?['products']?['data'] as List?)?.firstOrNull;
    final relatedList = productData?['relatedProducts'];
    if (relatedList is List) {
      return relatedList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final edges = relatedList?['edges'] as List<dynamic>? ?? [];
    return edges
        .map((e) => ProductModel.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }
}
