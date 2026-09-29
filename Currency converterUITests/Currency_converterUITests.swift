//
//  Currency_converterUITests.swift
//  Currency converterUITests
//
//  Created by Daniel Husiuk on 15.09.2026.
//

import XCTest

final class CurrencyConverterUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testViewControllerResponse() throws {
        let sellButton = app.buttons["sellButton"]
        let buyButton = app.buttons["buyButton"]
        let shareButton = app.buttons["shareButton"]
        
        let secondCurrencyButton = app.buttons["secondCurrencyButton"]
        let firstCurrencyTextField = app.textFields["firstCurrencyTextField"]
        let secondCurrencyTextField = app.textFields["secondCurrencyTextField"]
        let thirdCurrencyTextField = app.textFields["thirdCurrencyTextField"]
        
        XCTAssertTrue(firstCurrencyTextField.waitForExistence(timeout: 1))
        firstCurrencyTextField.tap()
        firstCurrencyTextField.typeText("25")
        
        XCTAssertTrue(secondCurrencyButton.exists)
        secondCurrencyButton.tap()
        
        XCTAssertTrue(app.cells["currencyCell_AED"].waitForExistence(timeout: 1))
        app.cells["currencyCell_AED"].tap()
        XCTAssertEqual(secondCurrencyButton.label, "AED")
        
        XCTAssertTrue(sellButton.exists)
        sellButton.tap()
        XCTAssertEqual(secondCurrencyTextField.value as? String, "90.907")
        XCTAssertEqual(thirdCurrencyTextField.value as? String, "1109.179")
        
        XCTAssertTrue(buyButton.exists)
        buyButton.tap()
        XCTAssertEqual(secondCurrencyTextField.value as? String, "92.743")
        XCTAssertEqual(thirdCurrencyTextField.value as? String, "1131.586")
        
        thirdCurrencyTextField.tap()
        app.buttons["Clear text"].firstMatch.tap()
        XCTAssertEqual(firstCurrencyTextField.value as? String, "Type here")
        XCTAssertEqual(secondCurrencyTextField.value as? String, "Or here")
        XCTAssertEqual(thirdCurrencyTextField.value as? String, "Or even here")
        
        XCTAssertTrue(shareButton.exists)
        shareButton.tap()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
