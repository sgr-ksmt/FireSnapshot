source 'https://cdn.cocoapods.org/'

target 'FireSnapshot' do
  use_frameworks!
  pod 'Firebase/Firestore', '~> 6.11'
  pod 'FirebaseFirestoreSwift', '~> 0.2'
  pod 'Firebase/Storage', '~> 6.11'

  target 'FireSnapshotTests' do
    pod 'Firebase/Core', '~> 6.11'
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
  end
end