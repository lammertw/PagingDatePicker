//
//  PagingDateAndMonthPickerCustomViewController.swift
//  PagingDatePicker
//
//  Created by Lammert Westerhoff on 28/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import PagingDatePicker
import SwiftDate

class PagingDateAndMonthPickerCustomViewController: UIViewController {
    
    @IBOutlet var datePickerControl: PagingDateAndMonthPickerViewControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        datePickerControl.monthPickerView.startDate = NSDate().startOf(.Month) - 3.months
        datePickerControl.monthPickerView.endDate = NSDate().startOf(.Month) + 2.months
        datePickerControl.monthPickerView.scrollToToday(false, force: true)
    }

}
