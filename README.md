# PagingDatePicker

[![CI Status](http://img.shields.io/travis/lammertw/PagingDatePicker.svg?style=flat)](https://travis-ci.org/Lammert Westerhoff/PagingDatePicker)
[![Version](https://img.shields.io/cocoapods/v/PagingDatePicker.svg?style=flat)](http://cocoapods.org/pods/PagingDatePicker)
[![License](https://img.shields.io/cocoapods/l/PagingDatePicker.svg?style=flat)](http://cocoapods.org/pods/PagingDatePicker)
[![Platform](https://img.shields.io/cocoapods/p/PagingDatePicker.svg?style=flat)](http://cocoapods.org/pods/PagingDatePicker)

This library consists of two components that can be used on it's own or together.
  One is a swipeable month picker and the other is a paging calendar date picker showing one month on each page.
  The month picker can be used as navigation header for the calendar date picker.

<p align="center">
	<img src="Screenshot.png" alt="Sample">
</p>

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Using the month picker

You can either create a new `MonthPickerView` from code or assign a view in your Storyboard with this type. After that you can assign its `delegate` to receive callbacks when a month has been selected.

### Using the paging date picker

You can either create a new `PagingDatePickerView` from code or assign a view in your Storyboard with this type. After that you can assign its `delegate` to receive callbacks when it has swiped to another page (i.e. month).

### Combining the month date picker and paging date picker

There are several ways to use the month picker and paging date picker together. All that needs to happen is that the change in month of one component is communicated to the other. You can do this manually or you can do this through one of the two provided ways:

- Use the `PagingDateAndMonthPickerView` to have a default layout with the month picker above the date picker.
- Create your own views in a Storyboard and connect them to the outlets of a `PagingDateAndMonthPickerViewControl`

See the Example project for sample usages.

## Installation

PagingDatePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PagingDatePicker"
```

## RSDayFlow

The __PagingDatePicker__ is currently build on top of [RSDayFlow](https://github.com/ruslanskorb/RSDayFlow) and has been build in a similar style to customize it. You can set a `datePickerViewDelegate` and `datePickerViewDataSource` on the `PagingDatePickerView` which will be propagated to the underlying `RSDFDatePickerView`.

## Author

Lammert Westerhoff, westerhoff@gmail.com

## License

PagingDatePicker is available under the MIT license. See the LICENSE file for more info.
