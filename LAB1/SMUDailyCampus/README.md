# SMU Daily Campus

A lightweight news client.

## Features

* Fetch news from [SMU Daily Campus](https://www.smudailycampus.com/category/news)
* Bookmark your favorite news or read it later
* Better reading typograph by Safari reader mode
* Pull to refresh the latest news
* Infinite scroll to load past news
* Automatically update timer with customized interval

## Environment

* Xcode 10.3
* Swift 5.0

## Dependencies

* [Just](https://github.com/dduan/Just)
* [SwiftSoup](https://github.com/scinfu/SwiftSoup)
* [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)
* [SwifterSwift](https://github.com/SwifterSwift/SwifterSwift)

The dependencies are managed by [Carthage](https://github.com/Carthage/Carthage), run `carthage bootstrap` to  get started and run `carthage update` to update the dependencies.

## Description

The first load of this app may be a little slow because of it will load a JavaScript VM to bypass the anti-crawler WAF. See `SMUDailyCampusClient.swift` for details.

Some items in settings seem a little useless because they are for the lab credits, but all of it works great.

The picker is embedded into a TableView cell to switch the homepage title.

The timer is implemented to update the latest news automatically. The interval of the timer (10s by default) can be set in the settings tab, set the interval to 0 to disable the timer.

The news tab implemented the Collection View and extended the Scroll View to shrink the title bar. The thumbnail of each post utilized the Image View. The favorites tab implemented the dynamic Table View.

## Screenshots

## Video

## TestFlight

Invitation link: [pending]