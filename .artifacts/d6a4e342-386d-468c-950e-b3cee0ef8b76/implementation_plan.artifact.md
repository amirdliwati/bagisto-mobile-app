# Fix Warnings and Errors in Flutter Project

This plan addresses several warnings and deprecated API usages identified across multiple files in the project. The primary focus is on fixing "current" files that the user might be working on, specifically `lib/features/search/presentation/pages/image_search_screen.dart` and `lib/main.dart`.

## Proposed Changes

### [Search Feature]

#### [MODIFY] [image_search_screen.dart](file:///C:/wamp64/www/bagisto/mobile/lib/features/search/presentation/pages/image_search_screen.dart)
- Replace deprecated `withOpacity(0.4)` with `withValues(alpha: 0.4)`.
- Add `mounted` checks before using `BuildContext` across asynchronous gaps in `_processCroppedImage`.

#### [MODIFY] [label_selection_screen.dart](file:///C:/wamp64/www/bagisto/mobile/lib/features/search/presentation/pages/label_selection_screen.dart)
- Replace deprecated `onPopInvoked` with `onPopInvokedWithResult`.

### [Core Widgets]

#### [MODIFY] [app_back_button.dart](file:///C:/wamp64/www/bagisto/mobile/lib/core/widgets/app_back_button.dart)
- Replace deprecated `withOpacity` with `withValues(alpha: ...)`.

### [Main Entry Point]

#### [MODIFY] [main.dart](file:///C:/wamp64/www/bagisto/mobile/lib/main.dart)
- Add `const` to `localizationsDelegates` list literal to satisfy `prefer_const_literals_to_create_immutables`.

### [Other Fixes]

#### [MODIFY] [settings_bottom_sheet.dart](file:///C:/wamp64/www/bagisto/mobile/lib/features/account/presentation/pages/settings_bottom_sheet.dart)
- Remove or comment out unused private methods `_buildLanguageSelector` and `_buildCurrencySelector`.

#### [MODIFY] [auth_repository.dart](file:///C:/wamp64/www/bagisto/mobile/lib/features/auth/data/repository/auth_repository.dart)
- Remove unused local variable `token`.

#### [MODIFY] [product_list_bloc.dart](file:///C:/wamp64/www/bagisto/mobile/lib/features/category/presentation/bloc/product_list_bloc.dart)
- Remove unused local variables `priceMin` and `priceMax`.

#### [MODIFY] [downloadable_products_page.dart](file:///C:/wamp64/www/bagisto/mobile/lib/features/account/presentation/pages/downloadable_products_page.dart)
- Replace deprecated `withOpacity`.

#### [MODIFY] [driver_main.dart](file:///C:/wamp64/www/bagisto/mobile/lib/driver_main.dart)
- Address `depend_on_referenced_packages` warning (likely by adding `flutter_driver` to `dev_dependencies` or handling it if it's misplaced).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure all identified warnings are resolved.
- Run `flutter test` (if applicable) to ensure no regressions.

### Manual Verification
- Verify that the image search screen still works as expected (camera, cropping, label selection).
- Verify that the settings bottom sheet still functions correctly.
