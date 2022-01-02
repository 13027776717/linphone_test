# Uncomment the next line to define a global platform for your project

# platform :ios, '9.0'


source "https://gitlab.linphone.org/BC/public/podspec.git"
source "https://github.com/CocoaPods/Specs.git"

target 'Linphone_call_test' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Linphone_call_test


	if ENV['PODFILE_PATH'].nil?
		pod 'linphone-sdk', '~> 5.0.48'
	else
		pod 'linphone-sdk', :path => ENV['PODFILE_PATH']  # local sdk
	end

end
