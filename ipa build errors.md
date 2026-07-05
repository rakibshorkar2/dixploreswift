Run set -eo pipefail
Command line invocation:
    /Applications/Xcode_16.app/Contents/Developer/usr/bin/xcodebuild -project DirXplore/DirXplore.xcodeproj -scheme DirXplore -configuration Release -sdk iphoneos -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO OTHER_CODE_SIGN_FLAGS=--no-strict BUILD_LIBRARY_FOR_DISTRIBUTION=NO

User defaults from command line:
    IDEDerivedDataPathOverride = /Users/runner/work/dixploreswift/dixploreswift/DerivedData
    IDEPackageSupportUseBuiltinSCM = YES

Build settings from command line:
    BUILD_LIBRARY_FOR_DISTRIBUTION = NO
    CODE_SIGN_IDENTITY = 
    CODE_SIGNING_ALLOWED = NO
    CODE_SIGNING_REQUIRED = NO
    OTHER_CODE_SIGN_FLAGS = --no-strict
    SDKROOT = iphoneos18.0

Resolve Package Graph


Resolved source packages:
  SwiftSoup: https://github.com/scinfu/SwiftSoup.git @ 2.13.6

2026-07-05 08:33:43.087 xcodebuild[24399:62513] Writing error result bundle to /var/folders/k8/j7r3p6cx43xdqhzy2rmp6tqr0000gn/T/ResultBundle_2026-05-07_08-33-0043.xcresult
xcodebuild: error: Found no destinations for the scheme 'DirXplore' and action build.
Error: Process completed with exit code 70.