//
//  AppStoreSnapshotsUITests.swift
//  AppStoreSnapshotsUITests
//
//  Created by Mircea Grelus on 2018-03-23.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import XCTest

class AppStoreSnapshotsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        let application = XCUIApplication()
        setupSnapshot(application)
        application.launchArguments.append("AppStoreSnapshot")
        application.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAppStoreSnapshot1() {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews

        // first delete whatever controls are already configured in the simulator
        deleteAllPaceTypes()
        // add controls
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["min/mi"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["min/km"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["kph"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["Marathon"].tap()
        // select second control
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).tap()
        // select a 5:10 pace
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "5")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "10")
        // takse first snapshot
        snapshot("01PacesScreen")
    }

    func testAppStoreSnapshot2() {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews

        deleteAllPaceTypes()

        let toggleTheme = app.navigationBars["Paces"].buttons["Toggle theme"]
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()

        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["kph"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["mph"].tap()
        app.collectionViews.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["Custom distance"].tap()
        app.scrollViews.otherElements.textFields["textInput"].typeText("60")
        app.scrollViews.otherElements.buttons["mi"].tap()
        app.toolbars.buttons["Done"].tap()
        // select second control
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "21")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "0")
        snapshot("02PacesScreen")
    }

    func testAppStoreSnapshot3() {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews

        deleteAllPaceTypes()

        let toggleTheme = app.navigationBars["Paces"].buttons["Toggle theme"]
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()
        toggleTheme.tap()

        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["min/km"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["min/mi"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["mph"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["Half Marathon"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["10k"].tap()
        // change races to mi
        let allCells = app.collectionViews.children(matching: .cell)
        allCells.element(boundBy: 3).buttons["Edit"].tap()
        app.scrollViews.otherElements.buttons["mi"].tap()
        allCells.element(boundBy: 4).buttons["Edit"].tap()
        app.scrollViews.otherElements.buttons["mi"].tap()
        //select
        collectionViewsQuery.children(matching: .cell).element(boundBy: 3).tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "1")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "40")
        app.pickerWheels.element(boundBy: 4).adjust(toPickerWheelValue: "00")
        snapshot("03PacesScreen")
    }

    func testAppStoreSnapshot4() {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews

        deleteAllPaceTypes()

        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["min/mi"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["min/km"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["kph"].tap()
        collectionViewsQuery.buttons["+"].tap()
        app.scrollViews.otherElements.buttons["Half Marathon"].tap()

        collectionViewsQuery.children(matching: .cell).element(boundBy: 0).tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "8")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "00")
        collectionViewsQuery.children(matching: .cell).element(boundBy: 0).tap()

        let halfMarathonCell = collectionViewsQuery.children(matching: .cell).element(boundBy: 3)
        halfMarathonCell.buttons["Edit"].tap()
        app.scrollViews.otherElements.buttons["km"].tap()
        halfMarathonCell.buttons["Edit"].tap()
        snapshot("04PacesScreen")
    }

    func deleteAllPaceTypes() {
        let app = XCUIApplication()

        let allCells = app.collectionViews.children(matching: .cell)
        while allCells.containing(.button, identifier: "Edit").count > 0 {
            allCells.element(boundBy: 0).buttons["Edit"].tap()
            app.scrollViews.otherElements.buttons["Delete"].tap()
        }
    }
    
}




