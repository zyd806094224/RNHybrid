#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'RNHybrid.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main app target
app_target = project.targets.find { |target| target.name == 'RNHybrid' }

# Fix build configurations for both Debug and Release
app_target.build_configurations.each do |config|
  puts "Fixing configuration: #{config.name}"
  
  # Set the correct SDK for simulator builds
  if config.name == 'Debug'
    config.build_settings['SDKROOT'] = 'iphonesimulator'
  elsif config.name == 'Release'
    config.build_settings['SDKROOT'] = 'iphonesimulator'
  end
  
  # Ensure PRODUCT_BUNDLE_IDENTIFIER is set
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.rnhybrid'
  
  # Disable code signing for simulator
  config.build_settings['CODE_SIGN_IDENTITY'] = '-'
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = ''
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  
  # Make sure INFOPLIST_FILE is set
  config.build_settings['INFOPLIST_FILE'] = 'RNHybrid/Info.plist'
  
  # Set deployment target
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.4'
  
  # Set proper device family
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  
  puts "  SDKROOT: #{config.build_settings['SDKROOT']}"
  puts "  PRODUCT_BUNDLE_IDENTIFIER: #{config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']}"
  puts "  CODE_SIGN_IDENTITY: #{config.build_settings['CODE_SIGN_IDENTITY']}"
end

# Save the project
project.save()

puts "\nProject configuration fixed!"