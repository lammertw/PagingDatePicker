//
//  PagingDateAndMonthPickerView.swift
//  FareCalendar
//
//  Created by Lammert Westerhoff on 22/03/16.
//  Copyright © 2016 NS International B.V. All rights reserved.
//

import UIKit

public class PagingDateAndMonthPickerView: UIView {

    @IBInspectable public var monthPickerHeight: CGFloat = 110.0

    public var datePickerViewClass = DatePickerWithoutMonthView.self

    private lazy var monthPickerView: MonthPickerView = {
        let view = MonthPickerView(frame: CGRectNull)
        self.addSubview(view)
        return view
    }()

    public var transitionStyle = UIPageViewControllerTransitionStyle.Scroll

    private lazy var datePickerView: PagingDatePickerView = {
        let view = PagingDatePickerView(frame: CGRectNull)
        view.datePickerViewClass = self.datePickerViewClass
        self.addSubview(view)
        return view
    }()

    public lazy var datePickerViewControl: PagingDateAndMonthPickerViewControl = {
        let control = PagingDateAndMonthPickerViewControl()
        control.monthPickerView = self.monthPickerView
        control.datePickerView = self.datePickerView
        return control
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func layoutSubviews() {
        datePickerViewControl.monthPickerView.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), monthPickerHeight)
        datePickerViewControl.datePickerView.frame = CGRectMake(0, monthPickerHeight, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - monthPickerHeight)
    }

}

public class PagingDateAndMonthPickerViewControl: NSObject {

    public var datePickerViewClass = DatePickerWithoutMonthView.self {
        didSet {
            datePickerView?.datePickerViewClass = datePickerViewClass
        }
    }

    @IBOutlet public var monthPickerView: MonthPickerView! {
        didSet {
            monthPickerView.delegate = self
        }
    }

    @IBOutlet public var datePickerView: PagingDatePickerView! {
        didSet {
            datePickerView.datePickerViewClass = datePickerViewClass
            datePickerView.delegate = self
        }
    }
}

extension PagingDateAndMonthPickerViewControl: MonthPickerViewDelegate {

    public func monthPickerView(monthPickerView: MonthPickerView, didSelectDate date: NSDate) {
        datePickerView.scrollToDate(date)
    }
}

extension PagingDateAndMonthPickerViewControl: PagingDatePickerViewDelegate {

    public func pagingDatePickerView(pagingDatePickerView: PagingDatePickerView, didPageToMonthDate date: NSDate) {
        monthPickerView.scrollToDate(date, animated: true)
    }
}
