# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

# Pods for Spika
def shared_pods
  pod 'Swinject'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'PhoneNumberKit', :git => 'https://github.com/marmelroy/PhoneNumberKit'
  pod 'Kingfisher', '~> 7.0'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'IKEventSource'
end

target 'Spika' do
  shared_pods
end

target 'Spika Dev' do
  shared_pods
end
