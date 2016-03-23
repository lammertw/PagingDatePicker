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

    public lazy var monthPickerView: MonthPickerView = {
        let view = MonthPickerView(frame: CGRectNull)
        view.delegate = self
        self.addSubview(view)
        return view
    }()

    public var transitionStyle = UIPageViewControllerTransitionStyle.Scroll

    public lazy var datePickerView: PagingDatePickerView = {
        let view = PagingDatePickerView(frame: CGRectNull)
        view.datePickerViewClass = self.datePickerViewClass
        view.delegate = self
        self.addSubview(view)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func layoutSubviews() {
        monthPickerView.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), monthPickerHeight)
        datePickerView.frame = CGRectMake(0, monthPickerHeight, CGRectGetWidth(bounds), CGRectGetHeight(bounds) - monthPickerHeight)
    }

}

extension PagingDateAndMonthPickerView: MonthPickerViewDelegate {

    public func monthPickerView(monthPickerView: MonthPickerView, didSelectDate date: NSDate) {
        datePickerView.scrollToDate(date)
    }
}

extension PagingDateAndMonthPickerView: PagingDatePickerViewDelegate {

    public func pagingDatePickerView(pagingDatePickerView: PagingDatePickerView, didPageToMonthDate date: NSDate) {
        monthPickerView.scrollToDate(date, animated: true)
    }
}
