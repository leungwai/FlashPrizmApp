//
//  FlashPrizmUITests.swift
//  FlashPrizmUITests
//
//  Created by Leung Wai Liu on 2/5/23.
//

import XCTest

final class FlashPrizmUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLogin() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Tap the "Login" button
        app.buttons["Log In"].tap()
        
        // Enter a username and password
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("howard@gmail.com")
        
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("howard")

//        let coordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        app.buttons["done"].tap()
        
        // Tap the "Submit" button
        app.buttons["Login"].tap()
        
        // Wait for the view controller to be popped
        let predicate = NSPredicate(format: "self.exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app.navigationBars["Main"])
        wait(for: [expectation], timeout: 5)
        
        // Verify that the login was successful
        XCTAssert(app.staticTexts["PrizmSets"].exists)
    }
    
    func testLogin(app: XCUIApplication, username: String, password: String) {
        // Tap the "Login" button
        app.buttons["Log In"].tap()
        
        // Enter a username and password
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText(username)
        
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText(password)

//        let coordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        app.buttons["done"].tap()
        
        // Tap the "Submit" button
        app.buttons["Login"].tap()
        
        // Wait for the view controller to be popped
        let predicate = NSPredicate(format: "self.exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app.navigationBars["Main"])
        wait(for: [expectation], timeout: 5)
        
        // Verify that the login was successful
        XCTAssert(app.staticTexts["PrizmSets"].exists)
    }
    
    func testLoginBadInput() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Tap the "Login" button
        app.buttons["Log In"].tap()
        
        // Enter a username and password
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("howard'\"@gmail.com")
        
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("howard")
        
        let coordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.tap()
        
        // Tap the "Submit" button
        app.buttons["Login"].tap()
        
        // Verify that the login was successful
        XCTAssert(app.staticTexts["Alert"].exists)
    }
    
    
    func verifyCreatePageEmptyContents(app: XCUIApplication, numFlashPrizms: Int, numSidesPerFlashPrizm: Int) {
        
        XCTAssert(app.staticTexts["Create PrizmSet"].exists)
        
        // ensuring the contents of the title cell exists
        XCTAssert(app.cells["titleCell"].exists)
        XCTAssert(app.textFields["titleTextField"].exists)
        XCTAssert(app.textFields["descriptionTextField"].exists)
        
        // ensuring that the contents of the Sides and the Terms Work
        
        for flashPrizmIndex in 1...numFlashPrizms {
            XCTAssert(app.cells["flashPrizmCell\(flashPrizmIndex)"].exists)
            XCTAssert(app.textFields["termForFlashPrizmCell\(flashPrizmIndex)"].exists)
            
            for sideIndex in 0..<numSidesPerFlashPrizm {
                XCTAssert(app.textFields["sideField\(sideIndex)ForFlashPrizm\(flashPrizmIndex)"].exists)
            }
            
            XCTAssert(app.buttons["addSideButtonForFlashPrizmCell\(flashPrizmIndex)"].exists)
             
        }
                
        // ensuring that add PrizmSet button exists
        XCTAssert(app.cells["addNewFlashPrizmCell"].exists)
        XCTAssert(app.buttons["addNewFlashPrizmButton"].exists)
        
    }
    
    func testCreatePageLoads() {
        let app = XCUIApplication()
        app.launch()
        
        // test login
        testLogin(app: app, username: "uitest@uitest.com", password: "uitestuitest")
        
        // going to "Create PrizmSet" page
        app.buttons["addFAB"].tap()
        
        // verifying the contents of the default Create PrizmSet page
        verifyCreatePageEmptyContents(app: app, numFlashPrizms: 3, numSidesPerFlashPrizm: 2)
    }
    
    func testAddNewPrizmsInCreatePage(amount:Int) {
        let app = XCUIApplication()
        app.launch()
        
        // test login
        testLogin(app: app, username: "uitest@uitest.com", password: "uitestuitest")
        
        // going to "Create PrizmSet" page
        app.buttons["addFAB"].tap()
        
        // verifying the contents of the default Create PrizmSet page
        verifyCreatePageEmptyContents(app: app, numFlashPrizms: 3, numSidesPerFlashPrizm: 2)
        
        // adding new FlashPrizms, then verifying
        for newIndex in 1...amount {
            app.buttons["addNewFlashPrizmButton"].tap()
            
            verifyCreatePageEmptyContents(app: app, numFlashPrizms: 3 + newIndex, numSidesPerFlashPrizm: 2)
        }
        
    }
    
    func testMultipleAddNewFlashPrizms() {
        // running multiple tests to add multiple add FlashPrizms
        
        testAddNewPrizmsInCreatePage(amount: 1)
        
        testAddNewPrizmsInCreatePage(amount: 2)

        testAddNewPrizmsInCreatePage(amount: 3)
        
    }
    
    
    
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
