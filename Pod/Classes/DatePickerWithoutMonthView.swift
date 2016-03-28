//
//  DatePickerWithoutMonthView.swift
//  FareCalendar
//
//  Created by Lammert Westerhoff on 21/03/16.
//  Copyright © 2016 NS International B.V. All rights reserved.
//

import UIKit
import RSDayFlow

public class DatePickerWithoutMonthView: RSDFDatePickerView {

    override public func collectionViewLayoutClass() -> AnyClass! {
        return DatePickerWithoutMonthCollectionViewLayout.self
    }

    override public func monthHeaderClass() -> AnyClass! {
        return MonthHeader.self
    }

}

public class DatePickerWithoutMonthCollectionViewLayout: RSDFDatePickerCollectionViewLayout {

    override public func selfHeaderReferenceSize() -> CGSize {
        return CGSize(width: 1, height: 1)
    }

}

private class MonthHeader: RSDFDatePickerMonthHeader {

    override func layoutSubviews() {
        hidden = true
    }

}
