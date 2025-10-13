# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in the Android Gradle plugin.

# Keep UniFFI generated classes
-keep class uniffi.** { *; }
-keep class template.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
