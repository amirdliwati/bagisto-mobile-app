# Fix "Unauthenticated" Error and Implement Global Logout on Session Expiry

The app is receiving an "Unauthenticated" error from the Bagisto GraphQL API, which is correctly mapped to a "session expired" message by the `ErrorMapper`. However, the app currently doesn't automatically log out the user when this happens, leaving them stuck with an error state.

## Proposed Changes

### [Core] [GraphQL]

#### [MODIFY] [graphql_client.dart](file:///C:/wamp64/www/bagisto/mobile/lib/core/graphql/graphql_client.dart)
- Add a global `StreamController` to broadcast authentication errors (specifically 401/Unauthenticated).
- Update `_createLoggingLink` to detect "Unauthenticated" messages in GraphQL errors and emit an event to the stream.
- Enhance `LoggingHttpClient` to log the `Authorization` header (truncated) for easier debugging of auth issues.

### [Core] [Error Handling]

#### [MODIFY] [error_mapper.dart](file:///C:/wamp64/www/bagisto/mobile/lib/core/error/error_mapper.dart)
- Export a way to check if an error is an authentication error (already exists as a check, but we can make it more explicit).

### [App Level]

#### [MODIFY] [main.dart](file:///C:/wamp64/www/bagisto/mobile/lib/main.dart)
- In `_AppWithAuthCartSyncState`, listen to the global authentication error stream from `GraphQLClientProvider`.
- When an authentication error is received, dispatch an `AuthLogoutRequested` event to the `AuthBloc` to automatically log out the user and clean up local data.

## Verification Plan

### Automated Tests
- This change is hard to test with unit tests without mocking the entire link chain, but we can verify that the stream emits events when expected.

### Manual Verification
- Log in to the app.
- Manually corrupt the token in `AuthStorage` or wait for it to expire (if possible).
- Navigate to the "Orders" page.
- Verify that the app automatically logs out and redirects to the login screen instead of just showing a SnackBar error.
