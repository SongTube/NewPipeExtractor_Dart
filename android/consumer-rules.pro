# Shipped to consuming apps so a release build with R8 works out of the box.

# Rhino (pulled in transitively by NewPipeExtractor to run YouTube's player JS)
# references desktop-JDK-only APIs that don't exist on Android: java.beans and
# javax.script for its scripting-engine wrapper, jdk.dynalink for the
# invokedynamic-based optimizer. Android runs Rhino's interpreter, so none of
# these are reached -- but R8 fails the build over the dangling references.
-dontwarn java.beans.**
-dontwarn javax.script.**
-dontwarn jdk.dynalink.**
-dontwarn org.mozilla.javascript.engine.**

# Rhino resolves these reflectively when it optimises compiled scripts.
-keep class org.mozilla.javascript.** { *; }

# protobuf-javalite parses YouTube's protobuf payloads reflectively.
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite {
    <fields>;
}
-dontwarn com.google.protobuf.**

# The extractor looks services up by class name.
-keep class org.schabi.newpipe.extractor.** { *; }
-dontwarn org.schabi.newpipe.extractor.**
