#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint telegram_login.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'telegram_login'
  s.version          = '0.0.1'
  s.summary          = 'Telegram Login SDK for Flutter (iOS)'
  s.description      = <<-DESC
A Flutter plugin that provides Telegram Login functionality on iOS using the official TelegramLogin SDK.
                       DESC
  s.homepage         = 'https://github.com/TelegramMessenger/telegram-login-ios'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Telegram' => 'support@telegram.org' }
  s.source           = { :path => '.' }
  s.source_files = 'telegram_login/Sources/telegram_login/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'telegram_login_privacy' => ['telegram_login/Sources/telegram_login/PrivacyInfo.xcprivacy']}
end
