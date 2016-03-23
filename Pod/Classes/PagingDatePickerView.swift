//
//  PagingDateWithMonthViewController.swift
//  FareCalendar
//
//  Created by Lammert Westerhoff on 22/03/16.
//  Copyright © 2016 NS International B.V. All rights reserved.
//

import UIKit
import RSDayFlow
import SwiftDate

public protocol PagingDatePickerViewDelegate: class {

    func pagingDatePickerView(pagingDatePickerView: PagingDatePickerView, didPageToMonthDate date: NSDate)
}

public class PagingDatePickerView: UIView {

    public var datePickerViewClass = RSDFDatePickerView.self

    public var transitionStyle = UIPageViewControllerTransitionStyle.Scroll

    public weak var delegate: PagingDatePickerViewDelegate?

    public weak var datePickerViewDelegate: RSDFDatePickerViewDelegate? {
        didSet {
            if oldValue != nil {
                pagingDatePickerPageViewController.datePickerViewDelegate = datePickerViewDelegate
            }
        }
    }

    public weak var datePickerViewDataSource: RSDFDatePickerViewDataSource? {
        didSet {
            if oldValue != nil {
                pagingDatePickerPageViewController.datePickerViewDataSource = datePickerViewDataSource
            }
        }
    }

    private lazy var pagingDatePickerPageViewController: PagingDatePickerPageViewController = {
        let vc = PagingDatePickerPageViewController(transitionStyle: self.transitionStyle, navigationOrientation: .Horizontal, options: [:], datePickerViewClass: self.datePickerViewClass)
        vc.pagingDatePickerViewDelegate = self
        vc.datePickerViewDelegate = self.datePickerViewDelegate
        vc.datePickerViewDataSource = self.datePickerViewDataSource
        self.addSubview(vc.view)
        return vc
    }()

    public override func layoutSubviews() {
        pagingDatePickerPageViewController.view.frame = bounds
    }

    public func scrollToDate(date: NSDate) {
        pagingDatePickerPageViewController.scrollToDate(date)
    }
}

extension PagingDatePickerView: PagingDatePickerPageViewControllerDelegate {
    public func pagingDatePickerViewControllerDidScrollToDate(date: NSDate) {
        delegate?.pagingDatePickerView(self, didPageToMonthDate: date)
    }
}


class PagingDatePickerViewController: UIViewController {

    let datePickerViewClass: RSDFDatePickerView.Type

    private let date: NSDate

    weak var datePickerViewDelegate: RSDFDatePickerViewDelegate?
    weak var datePickerViewDataSource: RSDFDatePickerViewDataSource?

    private init(date: NSDate, datePickerViewClass: RSDFDatePickerView.Type) {
        self.date = date
        self.datePickerViewClass = datePickerViewClass
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let datePickerView = datePickerViewClass.init(frame: CGRectNull, calendar: nil, startDate: date.startOf(.Month), endDate: date.endOf(.Month))
        datePickerView.delegate = datePickerViewDelegate
        datePickerView.dataSource = datePickerViewDataSource
        view = datePickerView
    }

}

protocol PagingDatePickerPageViewControllerDelegate: class {

    func pagingDatePickerViewControllerDidScrollToDate(date: NSDate)
}

class PagingDatePickerPageViewController: UIPageViewController {

    weak var pagingDatePickerViewDelegate: PagingDatePickerPageViewControllerDelegate?

    var datePickerViewClass = RSDFDatePickerView.self

    weak var datePickerViewDelegate: RSDFDatePickerViewDelegate?
    weak var datePickerViewDataSource: RSDFDatePickerViewDataSource?

    init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?, datePickerViewClass: RSDFDatePickerView.Type) {
        self.datePickerViewClass = datePickerViewClass
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var currentDate: NSDate? {
        return (viewControllers?.first as? PagingDatePickerViewController)?.date
    }

    private func pagingDatePickerViewController(date: NSDate) -> PagingDatePickerViewController {
        let vc = PagingDatePickerViewController(date: date, datePickerViewClass: datePickerViewClass)
        vc.datePickerViewDelegate = datePickerViewDelegate
        vc.datePickerViewDataSource = datePickerViewDataSource
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self

        setViewControllers([pagingDatePickerViewController(NSDate())], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        _ = currentDate.map { pagingDatePickerViewDelegate?.pagingDatePickerViewControllerDidScrollToDate($0) }
    }

    func scrollToDate(date: NSDate) {
        if let currentDate = currentDate where currentDate.startOf(.Month) != date.startOf(.Month) {
            setViewControllers([pagingDatePickerViewController(date)], direction: date > currentDate ? .Forward : .Reverse, animated: true, completion: nil)
        }
    }
}

extension PagingDatePickerPageViewController: UIPageViewControllerDataSource {

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return ((viewController as? PagingDatePickerViewController)?.date).map {
            pagingDatePickerViewController($0 - 1.months)
        }
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return ((viewController as? PagingDatePickerViewController)?.date).map {
            pagingDatePickerViewController($0 + 1.months)
        }
    }
}

extension PagingDatePickerPageViewController: UIPageViewControllerDelegate {

    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentDate = currentDate where completed {
            pagingDatePickerViewDelegate?.pagingDatePickerViewControllerDidScrollToDate(currentDate)
        }
    }
}
