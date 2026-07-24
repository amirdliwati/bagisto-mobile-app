# Fix Login and Registration - Bypass Backend Database Error

The previous attempt to fix the `Unknown column 'device_token'` error by commenting out the field in the `variables` map did not work. The backend continues to attempt a database update for `device_token`, likely because it defaults missing fields in the `LoginInput` object to `null`.

This plan aims to bypass this by changing the GraphQL mutation structure to explicitly omit `deviceToken` from the input object literal.

## Proposed Changes

### Auth Feature

#### [MODIFY] [auth_mutations.dart](file:///C:/wamp64/www/bagisto/mobile/lib/core/graphql/auth_mutations.dart)
- Update `loginMutation` to take `email` and `password` as direct variables and construct the `input` object literal without `deviceToken`.
- Update `registerMutation` similarly, omitting `deviceToken`.

#### [MODIFY] [auth_repository.dart](file:///C:/wamp64/www/bagisto/mobile/lib/features/auth/data/repository/auth_repository.dart)
- Update `login` and `register` methods to pass individual variables instead of a single `input` map.

## Verification Plan

### Manual Verification
- Attempt to log in and observe the GraphQL request logs.
- Verify if the `deviceToken` key is completely absent from the sent variables.
- Check if the backend still reports the `Unknown column 'device_token'` error.

### Automated Tests
- Run `flutter analyze` to ensure no syntax errors.
