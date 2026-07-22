/// Category model matching Bagisto GraphQL schema
/// Derived from: nextjs-commerce/src/graphql/catelog/queries/Category.ts
///               nextjs-commerce/src/graphql/catelog/queries/HomeCategories.ts
class CategoryModel {
  final String id;
  final int? numericId; // _id field from API
  final int? position;
  final String? logoPath;
  final String? logoUrl;
  final String? bannerUrl;
  final String? status;
  final CategoryTranslation? translation;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    this.numericId,
    this.position,
    this.logoPath,
    this.logoUrl,
    this.bannerUrl,
    this.status,
    this.translation,
    this.children = const [],
  });

  String get name => translation?.name ?? '';
  String get slug => translation?.slug ?? '';
  String get urlPath => translation?.urlPath ?? '';
  String? get imageUrl => logoUrl ?? logoPath;
  bool get isActive => status == '1';

  /// Factory for treeCategories response
  factory CategoryModel.fromTreeJson(Map<String, dynamic> json) {
    // Parse children from both list and cursor connection formats.
    List<CategoryModel> childrenList = [];
    final childrenData = json['children'];
    if (childrenData is List) {
      childrenList = childrenData
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromTreeJson)
          .toList();
    } else if (childrenData is Map<String, dynamic>) {
      final edges = childrenData['edges'] as List<dynamic>?;
      if (edges != null) {
        childrenList = edges
            .where((e) => e['node'] != null)
            .map((e) =>
                CategoryModel.fromTreeJson(e['node'] as Map<String, dynamic>))
            .toList();
      }
    }

    final translationData =
        json['translation'] as Map<String, dynamic>? ??
        {
          'id': json['id']?.toString(),
          'name': json['name'],
          'slug': json['slug'],
          'description': json['description'],
          'urlPath': json['urlPath'],
          'metaTitle': json['metaTitle'],
        };

    final rawNumericId = json['_id'];
    final parsedNumericId = rawNumericId is int
        ? rawNumericId
        : int.tryParse(rawNumericId?.toString() ?? '');
    final idValue = json['id']?.toString() ?? '';

    return CategoryModel(
      id: idValue,
      numericId: parsedNumericId ?? int.tryParse(idValue),
      position: json['position'] as int?,
      logoPath: json['logoPath'] as String?,
      logoUrl: json['logoUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      status: json['status']?.toString(),
      translation: CategoryTranslation.fromJson(translationData),
      children: childrenList,
    );
  }

  /// Factory for categories (home) cursor connection response
  factory CategoryModel.fromHomeCategoryJson(Map<String, dynamic> json) {
    final translationData =
        json['translation'] as Map<String, dynamic>? ??
        {
          'id': json['id']?.toString(),
          'name': json['name'],
          'slug': json['slug'],
        };

    final rawNumericId = json['_id'];
    final parsedNumericId = rawNumericId is int
        ? rawNumericId
        : int.tryParse(rawNumericId?.toString() ?? '');
    final idValue = json['id']?.toString() ?? '';

    return CategoryModel(
      id: idValue,
      numericId: parsedNumericId ?? int.tryParse(idValue),
      logoUrl: json['logoUrl'] as String?,
      position: json['position'] as int?,
      translation: CategoryTranslation.fromJson(translationData),
    );
  }
}

class CategoryTranslation {
  final String? id;
  final String? name;
  final String? slug;
  final String? description;
  final String? urlPath;
  final String? metaTitle;

  const CategoryTranslation({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.urlPath,
    this.metaTitle,
  });

  factory CategoryTranslation.fromJson(Map<String, dynamic> json) {
    return CategoryTranslation(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      urlPath: json['urlPath'] as String?,
      metaTitle: json['metaTitle'] as String?,
    );
  }
}

