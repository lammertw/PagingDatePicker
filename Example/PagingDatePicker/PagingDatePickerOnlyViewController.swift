//
//  PagingDatePickerOnlyViewController.swift
//  PagingDatePicker
//
//  Created by Lammert Westerhoff on 23/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PagingDatePicker
import RSDayFlow

class PagingDatePickerOnlyViewController: UIViewController {

    @IBOutlet weak var datePickerView: PagingDatePickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!

    private let monthFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMM, yyyy", options: 0, locale: nil)
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        datePickerView.delegate = self
        datePickerView.datePickerViewDelegate = self
    }



}

extension PagingDatePickerOnlyViewController: PagingDatePickerViewDelegate {

    func pagingDatePickerView(pagingDatePickerView: PagingDatePickerView, didPageToMonthDate date: NSDate) {
        monthLabel.text = monthFormatter.stringFromDate(date)
    }
}

extension PagingDatePickerOnlyViewController: RSDFDatePickerViewDelegate {

    func datePickerView(view: RSDFDatePickerView!, didSelectDate date: NSDate!) {
        dateLabel.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
    }
}
