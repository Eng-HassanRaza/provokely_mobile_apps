#!/usr/bin/env bash
set -euo pipefail

# Android: add provokely://oauth/instagram intent-filter
ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$ANDROID_MANIFEST" ]; then
  if ! grep -q "provokely\" android:host=\"oauth\"" "$ANDROID_MANIFEST"; then
    awk '
      /<activity[^>]*FlutterActivity/ && !x { print; print "        <intent-filter>"; print "            <action android:name=\"android.intent.action.VIEW\" />"; print "            <category android:name=\"android.intent.category.DEFAULT\" />"; print "            <category android:name=\"android.intent.category.BROWSABLE\" />"; print "            <data android:scheme=\"provokely\" android:host=\"oauth\" android:pathPrefix=\"/instagram\" />"; print "        </intent-filter>"; x=1; next }1' "$ANDROID_MANIFEST" > "$ANDROID_MANIFEST.tmp"
    mv "$ANDROID_MANIFEST.tmp" "$ANDROID_MANIFEST"
    echo "Android deep link intent-filter added."
  else
    echo "Android deep link already configured."
  fi
fi

# iOS: add URL type provokely
IOS_PLIST="ios/Runner/Info.plist"
if [ -f "$IOS_PLIST" ]; then
  if ! /usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes" "$IOS_PLIST" >/dev/null 2>&1; then
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$IOS_PLIST"
  fi
  if ! /usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes:0:CFBundleURLSchemes" "$IOS_PLIST" >/dev/null 2>&1; then
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$IOS_PLIST"
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string provokely" "$IOS_PLIST"
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$IOS_PLIST"
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string provokely" "$IOS_PLIST"
    echo "iOS URL scheme added."
  else
    echo "iOS URL scheme already present."
  fi
fi

echo "Platform config done."


