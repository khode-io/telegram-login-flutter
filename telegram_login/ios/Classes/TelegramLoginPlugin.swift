import Flutter
import UIKit

/// The main Flutter plugin class that bridges Dart method channel calls to the
/// native Telegram Login implementation.
///
/// This plugin handles:
/// - Configuration of the Telegram Login SDK with client credentials
/// - Initiating and managing the OAuth login flow
/// - Receiving and processing callback URLs from Telegram
/// - Delivering login results or errors back to Dart
///
/// The plugin supports both classic `UIApplicationDelegate` apps and modern
/// scene-based apps (iOS 13+). URL callbacks are automatically forwarded to
/// the Telegram SDK for processing.
public class TelegramLoginPlugin: NSObject, FlutterPlugin {

    /// Indicates whether the Telegram Login SDK has been configured with
    /// valid client credentials. Required before calling `login()`.
    private var isConfigured = false

    /// The pending Flutter result callback for an in-progress login flow.
    /// Set when `login()` is called, cleared when the result is delivered
    /// or the flow is cancelled via `cancelLogin()`.
    private var pendingLoginResult: FlutterResult?

    /// Registers the plugin with the Flutter engine.
    ///
    /// Creates the method channel, initializes the plugin instance, and
    /// registers for application/scene delegate callbacks to handle URL opens.
    ///
    /// - Parameter registrar: The Flutter plugin registrar for registering
    ///   method channels and application delegates.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "telegram_login",
            binaryMessenger: registrar.messenger()
        )
        let instance = TelegramLoginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        if #available(iOS 13.0, *) {
            registrar.addSceneDelegate(instance)
        }
    }

    /// Handles incoming method calls from the Dart side.
    ///
    /// Dispatches to the appropriate handler based on the method name:
    /// - `"configure"`: Configures the Telegram SDK with client credentials
    /// - `"login"`: Initiates the OAuth login flow
    /// - `"cancelLogin"`: Cancels the pending login and rejects the Dart Future
    /// - `"handleUrl"`: Forwards a URL to the Telegram SDK for processing
    ///
    /// - Parameters:
    ///   - call: The Flutter method call containing the method name and arguments
    ///   - result: The callback to return results or errors to Dart
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            handleConfigure(call: call, result: result)
        case "login":
            handleLogin(result: result)
        case "cancelLogin":
            handleCancelLogin(result: result)
        case "handleUrl":
            handleUrlCall(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Configures the Telegram Login SDK with client credentials.
    ///
    /// Validates the required arguments (`clientId`, `redirectUri`, `scopes`)
    /// and calls `TelegramLogin.configure()` on the main thread.
    ///
    /// Required arguments from `call.arguments`:
    /// - `clientId`: The Telegram bot ID (string)
    /// - `redirectUri`: The OAuth redirect URI (string)
    /// - `scopes`: Array of permission scopes (e.g., `["openid", "profile"]`)
    ///
    /// Optional arguments:
    /// - `fallbackScheme`: Custom URL scheme for fallback handling
    ///
    /// - Parameters:
    ///   - call: The Flutter method call containing configuration parameters
    ///   - result: The callback to signal success (nil) or an error
    private func handleConfigure(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let clientId = args["clientId"] as? String,
              let redirectUri = args["redirectUri"] as? String,
              let scopes = args["scopes"] as? [String] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing required configuration parameters",
                details: nil
            ))
            return
        }

        let fallbackScheme = args["fallbackScheme"] as? String

        DispatchQueue.main.async { [weak self] in
            TelegramLogin.configure(
                clientId: clientId,
                redirectUri: redirectUri,
                scopes: scopes,
                fallbackScheme: fallbackScheme
            )
            self?.isConfigured = true
            result(nil)
        }
    }

    /// Initiates the Telegram OAuth login flow.
    ///
    /// Requires `configure()` to have been called first. On success, stores
    /// the `result` callback in `pendingLoginResult` and calls
    /// `TelegramLogin.login()`; the completion handler delivers the result
    /// via `deliverLoginResult()`.
    ///
    /// Matching the underlying SDK, the plugin does not guard against a
    /// second concurrent `login()` call. Callers must ensure only one login
    /// is in flight at a time; otherwise the first Dart Future is orphaned
    /// by the SDK overwriting its pending completion.
    ///
    /// Possible error codes:
    /// - `NOT_CONFIGURED`: `configure()` was not called first
    ///
    /// - Parameter result: The Flutter result callback to return the login
    ///   result or an error to Dart
    private func handleLogin(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            guard self.isConfigured else {
                result(FlutterError(
                    code: "NOT_CONFIGURED",
                    message: "TelegramLogin.configure() was not called before login()",
                    details: nil
                ))
                return
            }

            self.pendingLoginResult = result

            TelegramLogin.login { [weak self] loginResult in
                DispatchQueue.main.async {
                    self?.deliverLoginResult(loginResult)
                }
            }
        }
    }

    /// Cancels the pending login flow and rejects the Dart Future.
    ///
    /// Cancel is terminal: the pending Dart Future is rejected with a
    /// `CANCELLED` error and any subsequent callback from the Telegram SDK
    /// (for example, if the user returns to Telegram and completes login
    /// after cancel) is silently discarded by `deliverLoginResult(_:)`.
    ///
    /// - Parameter result: The Flutter result callback returning `true` if
    ///   a pending login was cancelled, `false` if no login was in progress
    private func handleCancelLogin(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let pending = self.pendingLoginResult else {
                result(false)
                return
            }
            self.pendingLoginResult = nil
            TelegramLogin.cancel()
            pending(FlutterError(
                code: "CANCELLED",
                message: "The user cancelled the login",
                details: nil
            ))
            result(true)
        }
    }

    /// Handles a URL callback forwarded from Dart (manual URL handling).
    ///
    /// Typically used when the app receives a URL through a mechanism not
    /// covered by automatic delegate forwarding (e.g., deep links handled
    /// by Flutter's navigation system). Validates the URL argument and
    /// forwards it to the Telegram SDK.
    ///
    /// Required arguments from `call.arguments`:
    /// - `url`: The callback URL string from Telegram
    ///
    /// - Parameters:
    ///   - call: The Flutter method call containing the URL to handle
    ///   - result: The Flutter result callback returning `true` on success
    private func handleUrlCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Invalid URL provided",
                details: nil
            ))
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
            result(true)
        }
    }

    /// Forwards a URL to the Telegram Login SDK for processing.
    ///
    /// Must be called on the main actor. The SDK processes the URL to extract
    /// the authorization code and complete the OAuth flow.
    ///
    /// - Parameter url: The callback URL received from Telegram
    @MainActor
    private func forwardUrl(_ url: URL) {
        TelegramLogin.handle(url)
    }

    /// Delivers a login result from the Telegram SDK to Dart.
    ///
    /// If a Dart Future is pending, resolves it with the id token on success
    /// or rejects it with a `FlutterError` on failure. If no Future is
    /// pending — either because the flow was already cancelled or because
    /// no login was ever started — the result is silently discarded.
    ///
    /// - Parameter loginResult: The result from the Telegram SDK containing
    ///   either the `LoginData` on success or an `Error` on failure
    private func deliverLoginResult(_ loginResult: Result<LoginData, Error>) {
        guard let pending = pendingLoginResult else { return }
        pendingLoginResult = nil
        switch loginResult {
        case .success(let data):
            pending(["idToken": data.idToken])
        case .failure(let error):
            let (code, message) = Self.mapError(error)
            pending(FlutterError(code: code, message: message, details: nil))
        }
    }

    /// Maps a Telegram SDK or system error to a Flutter error code and message.
    ///
    /// Handles three categories of errors:
    /// 1. **TelegramLoginError**: Domain-specific errors from the Telegram SDK
    ///    (e.g., not configured, missing auth code, server errors, cancellation)
    /// 2. **Network errors**: `URLSession` errors from `NSURLErrorDomain`, surfaced
    ///    as `NETWORK_ERROR` so the app can suggest retries
    /// 3. **Unknown errors**: Any other errors mapped to `UNKNOWN_ERROR`
    ///
    /// - Parameter error: The error to map
    /// - Returns: A tuple of `(errorCode, errorMessage)` for constructing
    ///   a `FlutterError`
    private static func mapError(_ error: Error) -> (String, String) {
        if let tgError = error as? TelegramLoginError {
            switch tgError {
            case .notConfigured:
                return ("NOT_CONFIGURED", "TelegramLogin.configure() was not called before login()")
            case .noAuthorizationCode:
                return ("NO_AUTH_CODE", "The callback URL did not contain an authorization code")
            case .serverError(let statusCode):
                return ("SERVER_ERROR", "Server error: " + String(statusCode))
            case .requestFailed(let reason):
                return ("REQUEST_FAILED", reason)
            case .cancelled:
                return ("CANCELLED", "The user cancelled the login")
            }
        }

        // The SDK re-throws `URLSession` errors un-wrapped from the token
        // exchange. Surface those as a dedicated NETWORK_ERROR so the app can
        // suggest a retry rather than showing a raw NSError dump.
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return ("NETWORK_ERROR", nsError.localizedDescription)
        }

        return ("UNKNOWN_ERROR", error.localizedDescription)
    }

    // MARK: - UIApplicationDelegate forwarding (classic AppDelegate apps)
    //
    // These methods are called by Flutter when the app receives URL callbacks
    // through standard UIApplicationDelegate mechanisms. They forward URLs to
    // the Telegram SDK for OAuth callback processing.

    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
        }
        return true
    }

    /// Handles universal link continuations for Web-based OAuth callbacks.
    ///
    /// Called when the app is opened via a universal link (e.g., HTTPS URL
    /// associated with the app's domain). Checks if the activity is a web
    /// browsing activity and forwards the URL to the Telegram SDK.
    ///
    /// - Parameters:
    ///   - application: The shared UIApplication instance
    ///   - userActivity: The NSUserActivity containing the web URL
    ///   - restorationHandler: Unused restoration handler
    /// - Returns: `true` if the URL was handled (was a web browsing URL),
    ///   `false` otherwise
    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
        }
        return true
    }
}

// MARK: - FlutterSceneLifeCycleDelegate (scene-based apps, iOS 13+)
//
// These methods are called by Flutter for apps using the UIScene lifecycle
// (iOS 13+). They handle URL callbacks in modern scene-based apps.

@available(iOS 13.0, *)
extension TelegramLoginPlugin: FlutterSceneLifeCycleDelegate {

    /// Handles URL open requests in a scene-based app.
    ///
    /// Called when the app receives a URL through a custom scheme
    /// (e.g., `tglogin://callback`). Extracts the first URL from the
    /// context set and forwards it to the Telegram SDK.
    ///
    /// - Parameters:
    ///   - scene: The UIScene that received the URL
    ///   - URLContexts: A set of UIOpenURLContext objects containing URLs
    /// - Returns: `true` if a URL was handled, `false` otherwise
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        guard let url = URLContexts.first?.url else { return false }
        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
        }
        return true
    }

    /// Handles universal link continuations in a scene-based app.
    ///
    /// Called when the app is opened via a universal link during a scene
    /// transition. Checks if the activity is a web browsing activity and
    /// forwards the URL to the Telegram SDK for OAuth callback processing.
    ///
    /// - Parameters:
    ///   - scene: The UIScene that received the activity
    ///   - userActivity: The NSUserActivity containing the web URL
    /// - Returns: `true` if the URL was handled (was a web browsing URL),
    ///   `false` otherwise
    public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
        }
        return true
    }
}
