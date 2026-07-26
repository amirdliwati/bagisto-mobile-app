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
  static final List<ThemeCustomization> _fallbackCustomizations = [
    const ThemeCustomization(
      id: '1',
      type: 'image_carousel',
      name: 'Image Carousel',
      status: true,
      sortOrder: 1,
      options: {
        'images': [
          {
            'image': 'storage/theme/1/ZqYVhtxRA2koM67DHqwvArVONh3XOb1W9m6Sn2om.webp',
            'title': 'Get Ready For New Collection',
            'link': 'formal-wear-female',
          },
          {
            'image': 'storage/theme/1/SPCKhIhBLNefg5l8zOy2smdBIxJnbOfCYZl1AJkn.webp',
            'title': 'Get Ready For New Collection',
            'link': 'formal-wear-men',
          },
          {
            'image': 'storage/theme/1/GmjHjq4QXsITivV0T60cGyxOxmuzUHLsZTNRuKhw.webp',
            'title': 'Get Ready For New Collection',
            'link': 'active-wear-female',
          },
          {
            'image': 'storage/theme/1/iu019y58PRUW73rJ60fhmg3Z6KKZpRhZEZ9MTul6.webp',
            'title': 'Get Ready For New Collection',
            'link': 'smart-home-automation',
          },
          {
            'image': 'storage/theme/1/ezX0NbDbgTLg6FIgFRdCqiFLBGfwcl33XYwFtFzd.webp',
            'title': 'Get Ready For New Collection',
            'link': 'mobile-phones-accessories',
          },
          {
            'image': 'storage/theme/1/pLAygTBe57DpMzDzBsb9qnELlQ7bve38gSj0Qp9z.webp',
            'title': 'Get Ready For New Collection',
            'link': 'laptops-tablets',
          }
        ]
      },
    ),
    const ThemeCustomization(
      id: '2',
      type: 'category_carousel',
      name: 'Category Carousel',
      status: true,
      sortOrder: 2,
      options: {},
    ),
    const ThemeCustomization(
      id: '3',
      type: 'product_carousel',
      name: 'Featured Products',
      status: true,
      sortOrder: 3,
      options: {
        'filters': {
          'limit': '6',
          'sort': 'created_at-desc',
        }
      },
    ),
    const ThemeCustomization(
      id: '4',
      type: 'static_content',
      name: 'Home Offer',
      status: true,
      sortOrder: 3,
      options: {
        'html': '''
          <div class="home-offer"><h1>Get UPTO 40% OFF on your 1st order SHOP NOW</h1></div>
        '''
      },
    ),
    const ThemeCustomization(
      id: '5',
      type: 'static_content',
      name: 'Collections',
      status: true,
      sortOrder: 5,
      options: {
        'html': '''
          <div class="top-collection-container">
            <div class="top-collection-header">
              <h2>The game with our new additions!</h2>
            </div>
            <div class="top-collection-grid container">
              <div class="top-collection-card">
                <a href="electronics" aria-label="The game with our new additions!">
                  <img src="" data-src="storage/theme/5/4hoQg7hhBHT3fbhRkz8oUOSSb9j1uTNCzNHwuQzM.webp" class="lazy" width="396" height="396" alt="The game with our new additions!">
                </a>
              </div>
              <div class="top-collection-card">
                <a href="mens" aria-label="The game with our new additions!">
                  <img src="" data-src="storage/theme/5/IfesGBXfOz2vKeWG5oRTapOFin22ss7otKC8bBYs.webp" class="lazy" width="396" height="396" alt="The game with our new additions!">
                </a>
              </div>
              <div class="top-collection-card">
                <a href="womens" aria-label="The game with our new additions!">
                  <img src="" data-src="storage/theme/5/aOJPIJDspbKvo8B9TYrXsFicY6iahXpPdt7xiWoe.webp" class="lazy" width="396" height="396" alt="The game with our new additions!">
                </a>
              </div>
              <div class="top-collection-card">
                <a href="formal-wear-men" aria-label="The game with our new additions!">
                  <img src="" data-src="storage/theme/5/ul5LjlJVlRJSmEortLgBxIcuhIEOGLqEAK77Koqi.webp" class="lazy" width="396" height="396" alt="The game with our new additions!">
                </a>
              </div>
              <div class="top-collection-card">
                <a href="formal-wear-female" aria-label="The game with our new additions!">
                  <img src="" data-src="storage/theme/5/ql6JQE5CfOXLLRXzPRzXlzf3zWULqRXLJTDAb82T.webp" class="lazy" width="396" height="396" alt="The game with our new additions!">
                </a>
              </div>
              <div class="top-collection-card">
                <a href="wellness" aria-label="The game with our new additions!">
                  <img src="" data-src="storage/theme/5/TDRu692hJcPbtrMA25FXq5AzBfsRSzqYu2ZZYjRI.webp" class="lazy" width="396" height="396" alt="The game with our new additions!">
                </a>
              </div>
            </div>
          </div>
        '''
      },
    ),
    const ThemeCustomization(
      id: '6',
      type: 'static_content',
      name: 'Bold Collections',
      status: true,
      sortOrder: 6,
      options: {
        'html': '''
          <div class="section-gap bold-collections container">
            <div class="inline-col-wrapper">
              <div class="inline-col-image-wrapper">
                <img src="" data-src="storage/theme/6/q4lrKThrQW1mGi1iVACHYoucWs8GZ1Vi9HnoLJwb.webp" class="lazy" width="632" height="510" alt="Get Ready for our new Bold Collections!">
              </div>
              <div class="inline-col-content-wrapper">
                <h2 class="inline-col-title"> Get Ready for our new Bold Collections! </h2> 
                <p class="inline-col-description">Introducing Our New Bold Collections! Elevate your style with daring designs and vibrant statements. Explore striking patterns and bold colors that redefine your wardrobe. Get ready to embrace the extraordinary!</p>
                <a href="wellness">
                  <button class="primary-button max-md:rounded-lg max-md:px-4 max-md:py-2.5 max-md:text-sm">View Collections</button>
                </a>
              </div>
            </div>
          </div>
        '''
      },
    ),
    const ThemeCustomization(
      id: '7',
      type: 'product_carousel',
      name: 'New Products',
      status: true,
      sortOrder: 7,
      options: {
        'filters': {
          'limit': '4',
          'sort': 'created_at-desc',
        }
      },
    ),
    const ThemeCustomization(
      id: '8',
      type: 'product_carousel',
      name: 'Hot Deals',
      status: true,
      sortOrder: 8,
      options: {
        'filters': {
          'limit': '6',
          'sort': 'created_at-desc',
        }
      },
    ),
  ];

  Future<List<ThemeCustomization>> fetchThemeCustomizations() async {
    // Read the user's preferred locale for selecting the right translation
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString(LocaleCubit.localeKey) ?? 'en';

    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ThemeQueries.getThemeCustomization),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        // Some deployments can return internal errors for this resolver.
        // Degrade gracefully so the rest of the home data can still load.
        return _fallbackCustomizations;
      }

      final customizationsData = result.data?['themeCustomizations'];
      if (customizationsData == null) {
        return _fallbackCustomizations;
      }

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

      final list = nodes
          .map(
            (node) => ThemeCustomization.fromJson(
              node,
              preferredLocale: locale,
            ),
          )
          .where((tc) => tc.status)
          .toList();

      if (list.isEmpty) {
        return _fallbackCustomizations;
      }

      return list..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (_) {
      return _fallbackCustomizations;
    }
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
