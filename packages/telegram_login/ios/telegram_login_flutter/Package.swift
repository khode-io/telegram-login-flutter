// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "telegram_login_flutter",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "telegram-login-flutter", targets: ["telegram_login_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/TelegramMessenger/telegram-login-ios", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "telegram_login_flutter",
            dependencies: [
                .product(name: "TelegramLogin", package: "telegram-login-ios")
            ]
        )
    ]
)