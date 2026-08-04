# Fix Gradle Build Failure due to JDK Incompatibility

The build is failing because Gradle (specifically the Kotlin DSL parser) is unable to parse the version string of the installed JDK (Java 25/26). This is a known issue when using cutting-edge JDK versions with Gradle versions that include older Kotlin compiler internals.

## User Review Required

> [!IMPORTANT]
> I am proposing to force Gradle to use **JDK 17** which is already installed on your system. This is the most stable and recommended version for current Android development.

## Proposed Changes

### Android Configuration

#### [MODIFY] [gradle.properties](file:///C:/wamp64/www/bagisto/mobile/android/gradle.properties)
- Add `org.gradle.java.home` pointing to JDK 17 to ensure Gradle runs with a compatible Java version.

## Verification Plan

### Manual Verification
- Run `flutter run` again and verify that the Gradle initialization phase completes successfully.
- Run `.\gradlew assembleDebug` from the `android` directory to ensure the build proceeds past the initialization.
