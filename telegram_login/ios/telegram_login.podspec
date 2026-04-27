#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint telegram_login.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'telegram_login'
  s.version          = '1.1.0'
  s.summary          = 'Telegram Login SDK for Flutter (iOS)'
  s.description      = <<-DESC
A Flutter plugin that provides Telegram Login functionality on iOS using ASWebAuthenticationSession and CryptoKit.
                       DESC
  s.homepage         = 'https://github.com/khode-io/telegram-login-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Khode' => 'developer@khode.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.framework = 'AuthenticationServices'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'telegram_login_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
