Run set -eo pipefail
  
Command line invocation:
    /Applications/Xcode_16.app/Contents/Developer/usr/bin/xcodebuild -project DirXplore/DirXplore.xcodeproj -scheme DirXplore -destination generic/platform=iOS -configuration Release -sdk iphoneos -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO OTHER_CODE_SIGN_FLAGS=--no-strict BUILD_LIBRARY_FOR_DISTRIBUTION=NO
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
2026-07-05 08:42:29.812 xcodebuild[2372:10209] Writing error result bundle to /var/folders/k8/j7r3p6cx43xdqhzy2rmp6tqr0000gn/T/ResultBundle_2026-05-07_08-42-0029.xcresult
xcodebuild: error: Unable to find a destination matching the provided destination specifier:
		{ generic:1, platform:iOS }
	Ineligible destinations for the "DirXplore" scheme:
		{ platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder, name:Any iOS Device, error:iOS 18.0 is not installed. To use with Xcode, first download and install the platform }
Error: Process completed with exit code 70