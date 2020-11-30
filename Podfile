# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'winnerlights-ios-mobile-client' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for winnerlights-ios-mobile-client
  pod 'nRFMeshProvision'

  target 'winnerlights-ios-mobile-clientTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'winnerlights-ios-mobile-clientUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end

