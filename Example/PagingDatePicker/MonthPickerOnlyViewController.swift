//
//  MonthPickerOnlyViewController.swift
//  PagingDatePicker
//
//  Created by Lammert Westerhoff on 23/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PagingDatePicker

class MonthPickerOnlyViewController: UIViewController {

    @IBOutlet weak var monthPickerView: MonthPickerView!
    @IBOutlet weak var monthLabel: UILabel!

    private let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMM, yyyy", options: 0, locale: nil)
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        monthPickerView.delegate = self
    }

}

extension MonthPickerOnlyViewController: MonthPickerViewDelegate {

    func monthPickerView(monthPickerView: MonthPickerView, didSelectDate date: NSDate) {
        monthLabel.text = formatter.stringFromDate(date)
    }
}
