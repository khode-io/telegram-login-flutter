import Flutter
import UIKit
import XCTest

@testable import telegram_login

class RunnerTests: XCTestCase {

  func testPluginExists() {
    let plugin = TelegramLoginPlugin()
    XCTAssertNotNil(plugin)
  }

}
