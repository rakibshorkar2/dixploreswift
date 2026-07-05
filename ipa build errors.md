Run set -eo pipefail
  set -eo pipefail
  xcodebuild -project "DirXplore/DirXplore.xcodeproj" \
    -scheme "DirXplore" \
    -destination "generic/platform=iOS" \
    -configuration "Release" \
    -sdk "iphoneos" \
    -derivedDataPath "DerivedData" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    OTHER_CODE_SIGN_FLAGS="--no-strict" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=NO \
    2>&1 | tee xcodebuild.log
  shell: /bin/bash -e {0}
  env:
    PROJECT_PATH: DirXplore/DirXplore.xcodeproj
    SCHEME: DirXplore
    CONFIGURATION: Release
    SDK: iphoneos
    DERIVED_DATA: DerivedData
    DESTINATION: generic/platform=iOS
  
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
ExecuteExternalTool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc --version
ExecuteExternalTool /Applications/Xcode_16.app/Contents/Developer/usr/bin/actool --print-asset-tag-combinations --output-format xml1 /Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets
ExecuteExternalTool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -v -E -dM -isysroot /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.0.sdk -x c -c /dev/null
ExecuteExternalTool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld -version_details
ExecuteExternalTool /Applications/Xcode_16.app/Contents/Developer/usr/bin/actool --version --output-format xml1
Build description signature: 5d6015927c703ba778d2f8ccae274987
Build description path: /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/XCBuildData/5d6015927c703ba778d2f8ccae274987.xcbuilddata
ClangStatCache /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang-stat-cache /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.0.sdk /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SDKStatCaches.noindex/iphoneos18.0-22A3362-ecbf2746db86eb790eafe45896842e4a.sdkstatcache
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang-stat-cache /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.0.sdk -o /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SDKStatCaches.noindex/iphoneos18.0-22A3362-ecbf2746db86eb790eafe45896842e4a.sdkstatcache
CreateBuildDirectory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-create-build-directory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products
CreateBuildDirectory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-create-build-directory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore-e2472bc107798a8a3173aabd2578a00e-VFS-iphoneos/all-product-headers.yaml
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore-e2472bc107798a8a3173aabd2578a00e-VFS-iphoneos/all-product-headers.yaml
CreateBuildDirectory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-create-build-directory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos
CreateBuildDirectory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/EagerLinkingTBDs/Release-iphoneos
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-create-build-directory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/EagerLinkingTBDs/Release-iphoneos
CreateBuildDirectory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/PackageFrameworks
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-create-build-directory /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/PackageFrameworks
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/SwiftSoup.modulemap (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/SwiftSoup.modulemap
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/SwiftSoup.DependencyMetadataFileList (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/SwiftSoup.DependencyMetadataFileList
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup_const_extract_protocols.json (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup_const_extract_protocols.json
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.SwiftFileList (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.SwiftFileList
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.LinkFileList (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.LinkFileList
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup-OutputFileMap.json (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup-OutputFileMap.json
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore_const_extract_protocols.json (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore_const_extract_protocols.json
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore.SwiftFileList (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore.SwiftFileList
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore.SwiftConstValuesFileList (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore.SwiftConstValuesFileList
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore.LinkFileList (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore.LinkFileList
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore-OutputFileMap.json (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/Objects-normal/arm64/DirXplore-OutputFileMap.json
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore.hmap (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore.hmap
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore.DependencyMetadataFileList (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore.DependencyMetadataFileList
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-project-headers.hmap (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-project-headers.hmap
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-own-target-headers.hmap (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-own-target-headers.hmap
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-generated-files.hmap (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-generated-files.hmap
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-all-target-headers.hmap (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-all-target-headers.hmap
WriteAuxiliaryFile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-all-non-framework-target-headers.hmap (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    write-file /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/DirXplore-all-non-framework-target-headers.hmap
MkDir /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/DirXplore.app (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    /bin/mkdir -p /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/DirXplore.app
Copy /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/GeneratedModuleMaps-iphoneos/SwiftSoup.modulemap /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/SwiftSoup.modulemap (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -strip-unsigned-binaries -strip-deterministic -strip-tool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip -resolve-src-symlinks /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/SwiftSoup.modulemap /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/GeneratedModuleMaps-iphoneos
SwiftDriver SwiftSoup normal arm64 com.apple.xcode.tools.swift.compiler (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-SwiftDriver -- /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -module-name SwiftSoup -O -whole-module-optimization -enforce-exclusivity\=checked @/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.SwiftFileList -DSWIFT_PACKAGE -DXcode -plugin-path /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins/testing -enable-experimental-feature DebugDescriptionMacro -sdk /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.0.sdk -target arm64-apple-ios13.0 -g -module-cache-path /Users/runner/work/dixploreswift/dixploreswift/DerivedData/ModuleCache.noindex -Xfrontend -serialize-debugging-options -suppress-warnings -swift-version 6 -I /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos -I /Applications/Xco
SwiftDriver\ Compilation SwiftSoup normal arm64 com.apple.xcode.tools.swift.compiler (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-Swift-Compilation -- /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -module-name SwiftSoup -O -whole-module-optimization -enforce-exclusivity\=checked @/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.SwiftFileList -DSWIFT_PACKAGE -DXcode -plugin-path /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins/testing -enable-experimental-feature DebugDescriptionMacro -sdk /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.0.sdk -target arm64-apple-ios13.0 -g -module-cache-path /Users/runner/work/dixploreswift/dixploreswift/DerivedData/ModuleCache.noindex -Xfrontend -serialize-debugging-options -suppress-warnings -swift-version 6 -I /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos -I /Applicatio
SwiftCompile normal arm64 Compiling\ Attribute.swift,\ Attributes.swift,\ BinarySearch.swift,\ BooleanAttribute.swift,\ ByteSlice.swift,\ CharacterExt.swift,\ CharacterReader.swift,\ Cleaner.swift,\ Collector.swift,\ CombiningEvaluator.swift,\ Comment.swift,\ CssSelector.swift,\ DataNode.swift,\ DebugTrace.swift,\ Document.swift,\ DocumentType.swift,\ Element.swift,\ ElementQuery.swift,\ Elements.swift,\ Entities.swift,\ Evaluator.swift,\ Exception.swift,\ FormElement.swift,\ HtmlTreeBuilder.swift,\ HtmlTreeBuilderState.swift,\ LRUCache.swift,\ Mutex.swift,\ Node.swift,\ NodeTraversor.swift,\ NodeVisitor.swift,\ OrderedSet.swift,\ ParseError.swift,\ ParseErrorList.swift,\ ParseSettings.swift,\ Parser.swift,\ ParsingStrings.swift,\ Pattern.swift,\ Profiler.swift,\ QueryParser.swift,\ QueryParserCache.swift,\ SourceRange.swift,\ StreamReader.swift,\ String.swift,\ StringBuilder.swift,\ StringUtil.swift,\ StructuralEvaluator.swift,\ SwiftSoup.swift,\ Tag.swift,\ TextNode.swift,\ Token.swift,\ TokenQueue.swift,\ 
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-swiftTaskExecution -- /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -frontend -c /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/Attribute.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/Attributes.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/BinarySearch.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/BooleanAttribute.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/ByteSlice.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/CharacterExt.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/CharacterReader.swift /Users/runner/work/dixplor
CompileSwift normal arm64 (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend -c /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/Attribute.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/Attributes.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/BinarySearch.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/BooleanAttribute.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/ByteSlice.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/CharacterExt.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup/Sources/CharacterReader.swift /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourceP
SwiftDriverJobDiscovery normal arm64 Compiling Attribute.swift, Attributes.swift, BinarySearch.swift, BooleanAttribute.swift, ByteSlice.swift, CharacterExt.swift, CharacterReader.swift, Cleaner.swift, Collector.swift, CombiningEvaluator.swift, Comment.swift, CssSelector.swift, DataNode.swift, DebugTrace.swift, Document.swift, DocumentType.swift, Element.swift, ElementQuery.swift, Elements.swift, Entities.swift, Evaluator.swift, Exception.swift, FormElement.swift, HtmlTreeBuilder.swift, HtmlTreeBuilderState.swift, LRUCache.swift, Mutex.swift, Node.swift, NodeTraversor.swift, NodeVisitor.swift, OrderedSet.swift, ParseError.swift, ParseErrorList.swift, ParseSettings.swift, Parser.swift, ParsingStrings.swift, Pattern.swift, Profiler.swift, QueryParser.swift, QueryParserCache.swift, SourceRange.swift, StreamReader.swift, String.swift, StringBuilder.swift, StringUtil.swift, StructuralEvaluator.swift, SwiftSoup.swift, Tag.swift, TextNode.swift, Token.swift, TokenQueue.swift, Tokeniser.swift, TokeniserState.swift, Tr
SwiftDriver\ Compilation\ Requirements SwiftSoup normal arm64 com.apple.xcode.tools.swift.compiler (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore/DirXplore.xcodeproj
    builtin-Swift-Compilation-Requirements -- /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -module-name SwiftSoup -O -whole-module-optimization -enforce-exclusivity\=checked @/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.SwiftFileList -DSWIFT_PACKAGE -DXcode -plugin-path /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/host/plugins/testing -enable-experimental-feature DebugDescriptionMacro -sdk /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.0.sdk -target arm64-apple-ios13.0 -g -module-cache-path /Users/runner/work/dixploreswift/dixploreswift/DerivedData/ModuleCache.noindex -Xfrontend -serialize-debugging-options -suppress-warnings -swift-version 6 -I /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos -
SwiftMergeGeneratedHeaders /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/GeneratedModuleMaps-iphoneos/SwiftSoup-Swift.h /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup-Swift.h (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    builtin-swiftHeaderTool -arch arm64 /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup-Swift.h -o /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/GeneratedModuleMaps-iphoneos/SwiftSoup-Swift.h
Copy /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/arm64-apple-ios.swiftmodule /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.swiftmodule (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -strip-unsigned-binaries -strip-deterministic -strip-tool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip -resolve-src-symlinks -rename /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.swiftmodule /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/arm64-apple-ios.swiftmodule
Copy /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/arm64-apple-ios.swiftdoc /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.swiftdoc (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -strip-unsigned-binaries -strip-deterministic -strip-tool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip -resolve-src-symlinks -rename /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.swiftdoc /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/arm64-apple-ios.swiftdoc
Copy /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/arm64-apple-ios.abi.json /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.abi.json (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -strip-unsigned-binaries -strip-deterministic -strip-tool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip -resolve-src-symlinks -rename /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.abi.json /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/arm64-apple-ios.abi.json
Copy /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/Project/arm64-apple-ios.swiftsourceinfo /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.swiftsourceinfo (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    builtin-copy -exclude .DS_Store -exclude CVS -exclude .svn -exclude .git -exclude .hg -strip-unsigned-binaries -strip-deterministic -strip-tool /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip -resolve-src-symlinks -rename /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/SwiftSoup.build/Release-iphoneos/SwiftSoup.build/Objects-normal/arm64/SwiftSoup.swiftsourceinfo /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.swiftmodule/Project/arm64-apple-ios.swiftsourceinfo
Ld /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.o normal (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    /Applications/Xcode_16.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -Xlinker -reproducible -target arm64-apple-ios13.0 -r -isysroot /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.0.sdk -Os -w -L/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/EagerLinkingTBDs/Release-iphoneos -L/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos -L/Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/lib -F/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/EagerLinkingTBDs/Release-iphoneos -F/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos -iframework /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Frameworks -iframework /Applications/Xcode_16.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhon
GenerateAssetSymbols /Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    /Applications/Xcode_16.app/Contents/Developer/usr/bin/actool --output-format human-readable-text --notices --warnings --export-dependency-info /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/assetcatalog_dependencies --output-partial-info-plist /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/assetcatalog_generated_info.plist --app-icon AppIcon --compress-pngs --enable-on-demand-resources YES --development-region en --target-device iphone --target-device ipad --minimum-deployment-target 18.0 --platform iphoneos --compile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/DirXplore.app /Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets --bundle-identifier com.example.dirBrowser --generate-swift-asset-symbols /Users/runner/work/dixploreswift/dixploreswift/DerivedDa
CompileAssetCatalog /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/DirXplore.app /Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets (in target 'DirXplore' from project 'DirXplore')
    cd /Users/runner/work/dixploreswift/dixploreswift/DirXplore
    /Applications/Xcode_16.app/Contents/Developer/usr/bin/actool --output-format human-readable-text --notices --warnings --export-dependency-info /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/assetcatalog_dependencies --output-partial-info-plist /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/assetcatalog_generated_info.plist --app-icon AppIcon --compress-pngs --enable-on-demand-resources YES --development-region en --target-device iphone --target-device ipad --minimum-deployment-target 18.0 --platform iphoneos --compile /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/DirXplore.app /Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets
/* com.apple.actool.errors */
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets: error: No simulator runtime version from [<DVTBuildVersion 22F77>, <DVTBuildVersion 22G86>, <DVTBuildVersion 23A8464>, <DVTBuildVersion 23B86>, <DVTBuildVersion 23C54>] available to use with iphonesimulator SDK version <DVTBuildVersion 22A3362>
/* com.apple.actool.document.warnings */
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][40x40][][][2x][][][][]: warning: The file "Icon-40@2x-1.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][40x40][][][1x][][][][]: warning: The file "Icon-40.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][20x20][][][2x][][][][]: warning: The file "Icon-20@2x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][29x29][][][2x][][][][]: warning: The file "Icon-29@2x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][20x20][][][3x][][][][]: warning: The file "Icon-20@3x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][29x29][][][3x][][][][]: warning: The file "Icon-29@3x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][40x40][][][2x][][][][]: warning: The file "Icon-40@2x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][40x40][][][3x][][][][]: warning: The file "Icon-40@3x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][76x76][][][1x][][][][]: warning: The file "Icon-76.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][20x20][][][1x][][][][]: warning: The file "Icon-20.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][29x29][][][1x][][][][]: warning: The file "Icon-29.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][29x29][][][2x][][][][]: warning: The file "Icon-29@2x-1.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][60x60][][][2x][][][][]: warning: The file "Icon-60@2x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][76x76][][][2x][][][][]: warning: The file "Icon-76@2x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][83.5x83.5][][][2x][][][][]: warning: The file "Icon-83.5@2x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ipad][20x20][][][2x][][][][]: warning: The file "Icon-20@2x-1.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][iphone][60x60][][][3x][][][][]: warning: The file "Icon-60@3x.png" for the image set "AppIcon" does not exist.
/Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets:./AppIcon.appiconset/[][ios-marketing][1024x1024][][][1x][][][][]: warning: The file "Icon-1024.png" for the image set "AppIcon" does not exist.
/* com.apple.actool.compilation-results */
/Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Intermediates.noindex/DirXplore.build/Release-iphoneos/DirXplore.build/assetcatalog_generated_info.plist
RegisterExecutionPolicyException /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.o (in target 'SwiftSoup' from project 'SwiftSoup')
    cd /Users/runner/work/dixploreswift/dixploreswift/DerivedData/SourcePackages/checkouts/SwiftSoup
    builtin-RegisterExecutionPolicyException /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/SwiftSoup.o
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-Owholemodule, expected -Onone (in target 'SwiftSoup' from project 'SwiftSoup')
note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in target 'DirXplore' from project 'DirXplore')
** BUILD FAILED **
The following build commands failed:
	CompileAssetCatalog /Users/runner/work/dixploreswift/dixploreswift/DerivedData/Build/Products/Release-iphoneos/DirXplore.app /Users/runner/work/dixploreswift/dixploreswift/DirXplore/Resources/Assets.xcassets (in target 'DirXplore' from project 'DirXplore')
	Building project DirXplore with scheme DirXplore and configuration Release
(2 failures)
Error: Process completed with exit code 65.