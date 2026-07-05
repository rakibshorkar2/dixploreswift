Run set -eo pipefail
  
Command line invocation:
    /Applications/Xcode_15.4.app/Contents/Developer/usr/bin/xcodebuild -project DirXplore/DirXplore.xcodeproj -scheme DirXplore -destination generic/platform=iOS -configuration Release -sdk iphoneos -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO OTHER_CODE_SIGN_FLAGS=--no-strict BUILD_LIBRARY_FOR_DISTRIBUTION=NO
User defaults from command line:
    IDEDerivedDataPathOverride = /Users/runner/work/dixploreswift/dixploreswift/DerivedData
    IDEPackageSupportUseBuiltinSCM = YES
Build settings from command line:
    BUILD_LIBRARY_FOR_DISTRIBUTION = NO
    CODE_SIGN_IDENTITY = 
    CODE_SIGNING_ALLOWED = NO
    CODE_SIGNING_REQUIRED = NO
    OTHER_CODE_SIGN_FLAGS = --no-strict
    SDKROOT = iphoneos17.5
Resolve Package Graph
Resolved source packages:
  SwiftSoup: https://github.com/scinfu/SwiftSoup.git @ 2.9.6
Prepare packages
note: Using codesigning identity override: 
ComputeTargetDependencyGraph
note: Building targets in dependency order
note: Target dependency graph (3 targets)
    Target 'DirXplore' in project 'DirXplore'
        ➜ Explicit dependency on target 'SwiftSoup' in project 'SwiftSoup'
    Target 'SwiftSoup' in project 'SwiftSoup'
        ➜ Explicit dependency on target 'SwiftSoup' in project 'SwiftSoup'
    Target 'SwiftSoup' in project 'SwiftSoup' (no dependencies)
GatherProvisioningInputs
CreateBuildDescription
ExecuteExternalTool /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -v
ExecuteExternalTool /Applications/Xcode_15.4.app/Contents/Developer/usr/bin/actool --print-asset-tag-combinations --output-format xml1 /Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets
ExecuteExternalTool /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -v -E -dM -isysroot /Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.5.sdk -x c -c /dev/null
ExecuteExternalTool /Applications/Xcode_15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld -version_details
ExecuteExternalTool /Applications/Xcode_15.4.app/Contents/Developer/usr/bin/actool --version --output-format xml1
Build description signature: 357219433d4bdb063a35e99c02a56149
Build description path: /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/XCBuildData/357219433d4bdb063a35e99c02a56149.xcbuilddata
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj: warning: The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 18.0, but the range of supported deployment target versions is 12.0 to 17.5.99. (in target 'DirXplore' from project 'DirXplore')
error: SWIFT_VERSION '6.0' is unsupported, supported versions are: 4.0, 4.2, 5.0. (in target 'DirXplore' from project 'DirXplore')
** BUILD FAILED **
Error: Process completed with exit code 65.