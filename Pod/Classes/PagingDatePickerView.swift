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

@objc public protocol PagingDatePickerViewDelegate: class {

    optional func pagingDatePickerView(pagingDatePickerView: PagingDatePickerView, didCreateDatePickerView datePickerView: RSDFDatePickerView, forMonthDate date: NSDate)
    optional func pagingDatePickerView(pagingDatePickerView: PagingDatePickerView, didPageToMonthDate date: NSDate)
}

public class PagingDatePickerView: UIView {

    public var datePickerViewClass = RSDFDatePickerView.self

    public var transitionStyle = UIPageViewControllerTransitionStyle.Scroll

    public weak var delegate: PagingDatePickerViewDelegate?

    public var startDate: NSDate? {
        didSet {
            pagingDatePickerPageViewController.startDate = startDate
        }
    }
    public var endDate: NSDate? {
        didSet {
            pagingDatePickerPageViewController.endDate = endDate
        }
    }

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
        vc.startDate = self.startDate
        vc.endDate = self.endDate
        vc.datePickerViewDelegate = self.datePickerViewDelegate
        vc.datePickerViewDataSource = self.datePickerViewDataSource
        self.addSubview(vc.view)
        return vc
    }()

    public override func layoutSubviews() {
        pagingDatePickerPageViewController.view.frame = bounds
    }

    public func scrollToDate(date: NSDate, reload: Bool = false, animated: Bool = true) {
        pagingDatePickerPageViewController.scrollToDate(date, reload: reload, animated: animated)
    }
}

extension PagingDatePickerView: PagingDatePickerPageViewControllerDelegate {

    func pagingDatePickerViewControllerDidCreateDatePickerView(datePickerView: RSDFDatePickerView, forMonth date: NSDate) {
        delegate?.pagingDatePickerView?(self, didCreateDatePickerView: datePickerView, forMonthDate: date)
    }

    public func pagingDatePickerViewControllerDidScrollToDate(date: NSDate) {
        delegate?.pagingDatePickerView?(self, didPageToMonthDate: date)
    }
}

protocol PagingDatePickerViewControllerDelegate: class {

    func pagingDatePickerViewController(pagingDatePickerViewController: PagingDatePickerViewController, didCreateDatePickerView datePickerView: RSDFDatePickerView, forMonth date: NSDate)
}

class PagingDatePickerViewController: UIViewController {

    let datePickerViewClass: RSDFDatePickerView.Type

    private let date: NSDate

    weak var datePickerViewDelegate: RSDFDatePickerViewDelegate?
    weak var datePickerViewDataSource: RSDFDatePickerViewDataSource?
    weak var delegate: PagingDatePickerViewControllerDelegate?

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
        delegate?.pagingDatePickerViewController(self, didCreateDatePickerView: datePickerView, forMonth: date)
        view = datePickerView
    }

}

protocol PagingDatePickerPageViewControllerDelegate: class {

    func pagingDatePickerViewControllerDidCreateDatePickerView(datePickerView: RSDFDatePickerView, forMonth date: NSDate)
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

    var startDate: NSDate?
    var endDate: NSDate?

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var currentDate: NSDate? {
        return (viewControllers?.first as? PagingDatePickerViewController)?.date
    }

    private func firstPagingDatePickerViewController() -> PagingDatePickerViewController? {
        return pagingDatePickerViewController(NSDate()) ?? startDate.flatMap(pagingDatePickerViewController)
    }

    private func pagingDatePickerViewController(date: NSDate) -> PagingDatePickerViewController? {
        if startDate <= date && endDate == nil || endDate >= date {
            let vc = PagingDatePickerViewController(date: date, datePickerViewClass: datePickerViewClass)
            vc.datePickerViewDelegate = datePickerViewDelegate
            vc.datePickerViewDataSource = datePickerViewDataSource
            vc.delegate = self
            return vc
        }
        return nil
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self

        if let viewController = firstPagingDatePickerViewController() {
            setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            _ = currentDate.map { pagingDatePickerViewDelegate?.pagingDatePickerViewControllerDidScrollToDate($0) }
        }
    }

    func scrollToDate(date: NSDate, fallbackToStartDate: Bool = true, reload: Bool = false, animated: Bool = true) {
        if let currentDate = currentDate where reload || currentDate.startOf(.Month) != date.startOf(.Month) {
            if let vc = pagingDatePickerViewController(date) ?? (fallbackToStartDate ? startDate.flatMap(pagingDatePickerViewController) : nil) {
                setViewControllers([vc], direction: date > currentDate ? .Forward : .Reverse, animated: true, completion: nil)
            }
        }
    }
}

extension PagingDatePickerPageViewController: PagingDatePickerViewControllerDelegate {

    func pagingDatePickerViewController(pagingDatePickerViewController: PagingDatePickerViewController, didCreateDatePickerView datePickerView: RSDFDatePickerView, forMonth date: NSDate) {
        pagingDatePickerViewDelegate?.pagingDatePickerViewControllerDidCreateDatePickerView(datePickerView, forMonth: date)
    }
}

extension PagingDatePickerPageViewController: UIPageViewControllerDataSource {

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return ((viewController as? PagingDatePickerViewController)?.date).flatMap {
            pagingDatePickerViewController($0 - 1.months)
        }
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return ((viewController as? PagingDatePickerViewController)?.date).flatMap {
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
