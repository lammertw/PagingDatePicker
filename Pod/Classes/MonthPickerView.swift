//
//  MonthPickerView.swift
//  FareCalendar
//
//  Created by Lammert Westerhoff on 22/03/16.
//  Copyright © 2016 NS International B.V. All rights reserved.
//

import UIKit
import SwiftDate
import Darwin
import DynamicColor

private let MonthCellIdentifier = "MonthCellIdentifier"
private let MonthsInPastAndFuture = 16

@objc public protocol MonthPickerViewDelegate: class {

    func monthPickerView(monthPickerView: MonthPickerView, didSelectDate date: NSDate)

    optional func monthPickerView(monthPickerView: MonthPickerView, titleForMonthDate date: NSDate) -> NSAttributedString?
    optional func monthPickerView(monthPickerView: MonthPickerView, subtitleForMonthDate date: NSDate) -> NSAttributedString?
}

public class MonthPickerView: UIView {

    private var collectionView: MonthPickerCollectionView?

    public weak var delegate: MonthPickerViewDelegate?

    private var selectedDate: NSDate? {
        didSet {
            if let selectedDate = selectedDate where selectedDate.startOf(.Month, inRegion: region) != oldValue?.startOf(.Month, inRegion: region) {
                delegate?.monthPickerView(self, didSelectDate: selectedDate)
            }
        }
    }

    public var collectionViewClass = MonthPickerCollectionView.self {
        didSet {
            collectionView = nil
            setNeedsLayout()
        }
    }

    public var monthPickerCollectionViewLayoutClass = MonthPickerCollectionViewLayout.self {
        didSet {
            collectionView?.collectionViewLayout = monthPickerCollectionViewLayoutClass.init()
        }
    }

    public var monthPickerCellClass = MonthPickerCell.self {
        didSet {
            collectionView?.registerClass(monthPickerCellClass, forCellWithReuseIdentifier: MonthCellIdentifier)
            collectionView?.reloadData()
        }
    }

    public var region = Region() {
        didSet {
            monthDateFormatter = createMonthDateFormatter()
        }
    }

    private var monthDateFormatter: NSDateFormatter!

    private func determineFromDate() -> NSDate {
        return (startDate?.startOf(.Month, inRegion: region) ?? MonthsInPastAndFuture.months.ago(inRegion: region)) - 2.months
    }

    private func determineToDate() -> NSDate {
        return (endDate.map { $0.startOf(.Month, inRegion: region) + 1.months } ?? MonthsInPastAndFuture.months.fromNow(inRegion: region)) + 2.months
    }

    public var startDate: NSDate? = nil {
        didSet {
            fromDate = determineFromDate()
        }
    }

    public var endDate: NSDate? = nil {
        didSet {
            toDate = determineToDate()
        }
    }

    private var fromDate: NSDate! {
        didSet {
            collectionView?.reloadData()
        }
    }
    private var toDate: NSDate! {
        didSet {
            collectionView?.reloadData()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitializer()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitializer()
    }

    private func commonInitializer() {
        fromDate = determineFromDate()
        toDate = determineToDate()
        monthDateFormatter = createMonthDateFormatter()
    }

    private func createCollectionView() {
        collectionView = collectionViewClass.init(frame: bounds, collectionViewLayout: monthPickerCollectionViewLayoutClass.init())
        collectionView?.monthPickerView = self
        collectionView?.backgroundColor = backgroundColor
        collectionView?.showsHorizontalScrollIndicator = false
        addSubview(collectionView!)
        collectionView?.registerClass(monthPickerCellClass, forCellWithReuseIdentifier: MonthCellIdentifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self

        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()

        scrollToToday(false)
    }

    public func scrollToToday(animated: Bool, force: Bool = false) {
        scrollToDate(NSDate(), animated: animated, force: force)
    }

    public func scrollToDate(date: NSDate, animated: Bool, force: Bool = false) {
        var scrollToDate = date
        if startDate != nil && startDate > date {
            scrollToDate = startDate!
        }

        if endDate != nil && endDate < scrollToDate {
            scrollToDate = endDate!
        }

        if !force && scrollToDate.startOf(.Month) == selectedDate?.startOf(.Month) {
            return
        }

        guard let collectionView = collectionView else { return }
        let layout = collectionView.collectionViewLayout

        let dateYearMonthComponents = region.calendar.components([.Year, .Month], fromDate: scrollToDate)
        guard let month = region.calendar.dateFromComponents(dateYearMonthComponents) else { return }

        if fromDate > date || toDate < date {
            if startDate == nil {
                fromDate = month.startOf(.Month) - MonthsInPastAndFuture.months
            }

            if endDate == nil {
                toDate = month.startOf(.Month) + MonthsInPastAndFuture.months
            }

            collectionView.reloadData()
            layout.invalidateLayout()
            layout.prepareLayout()
        }

        let indexPath = NSIndexPath(forItem: itemIndexForDate(scrollToDate), inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)

        selectedDate = scrollToDate
    }

    public func createMonthDateFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.calendar = region.calendar
        formatter.locale = region.locale
        formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMM yyyy", options: 0, locale: region.locale)
        return formatter
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if collectionView == nil {
            createCollectionView()
        }
        collectionView?.frame = bounds
    }

    private func dateForFirstDayInItem(itemIndex: Int) -> NSDate {
        return fromDate + itemIndex.months
    }

    private func itemIndexForDate(date: NSDate) -> Int {
        return region.calendar.components(.Month, fromDate: dateForFirstDayInItem(0), toDate: date, options: []).month
    }

    private func shiftDates(months: Int) {
        guard let collectionView = collectionView else { return }

        let layout = collectionView.collectionViewLayout
        let visibleCells = collectionView.visibleCells()

        guard let fromIndex = visibleCells.first.flatMap(collectionView.indexPathForCell)?.item else { return }
        let fromItemOfDate = dateForFirstDayInItem(fromIndex)

        guard let fromAttrs = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: fromIndex, inSection: 0)) else { return }
        let fromItemOrigin = convertPoint(fromAttrs.frame.origin, fromView: collectionView)

        if startDate == nil {
            fromDate = fromDate + months.months
        }
        if endDate == nil {
            toDate = toDate + months.months
        }

        collectionView.reloadData()
        layout.invalidateLayout()
        layout.prepareLayout()

        let toItem = itemIndexForDate(fromItemOfDate)
        if let toAttrs = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: toItem, inSection: 0)) {
            let toItemOrigin = convertPoint(toAttrs.frame.origin, fromView: collectionView)
            collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x + (toItemOrigin.x - fromItemOrigin.x), y: collectionView.contentOffset.y)
        }
    }

    private func appendPastDates() {
        shiftDates(-MonthsInPastAndFuture)
    }

    private func appendFutureDates() {
        shiftDates(MonthsInPastAndFuture)
    }

    private func collectionViewWillLayoutSubviews() {
        guard let collectionView = collectionView else { return }
        if startDate == nil && collectionView.contentOffset.x < CGRectGetWidth(bounds) {
            appendPastDates()
        }

        if endDate == nil && collectionView.contentOffset.x > collectionView.contentSize.width - CGRectGetWidth(collectionView.bounds) * 2 {
            appendFutureDates()
        }
    }

}

extension MonthPickerView: UICollectionViewDataSource {

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return region.calendar.components(.Month, fromDate: fromDate, toDate: toDate, options: []).month
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MonthCellIdentifier, forIndexPath: indexPath) as! MonthPickerCell

        let date = dateForFirstDayInItem(indexPath.item)
        cell.date = date

        if let attributedStringFunction = delegate?.monthPickerView(_:titleForMonthDate:) {
            cell.monthLabel.attributedText = attributedStringFunction(self, titleForMonthDate: date)
        } else {
            cell.monthLabel.text = monthDateFormatter.stringFromDate(date)
        }

        cell.subtitleLabel.attributedText = delegate?.monthPickerView?(self, subtitleForMonthDate: date)
        cell.setNeedsLayout()

        return cell
    }

    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.hidden = indexPath.item < 2 || indexPath.item >= self.collectionView(collectionView, numberOfItemsInSection: 0) - 2
    }

}

extension MonthPickerView: UICollectionViewDelegate {

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)

        selectedDate = dateForFirstDayInItem(indexPath.item)
    }
}

extension MonthPickerView: UIScrollViewDelegate {

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        selectMiddleDate()
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            selectMiddleDate()
        }
    }

    private func selectMiddleDate() {
        guard let collectionView = collectionView else { return }
        let visibleCells = collectionView.visibleCells()

        let middleIndex = visibleCells.count / 2
        if let indexPath = collectionView.indexPathForCell(visibleCells[middleIndex]) {
            if indexPath.item < 2 {
                scrollToDate(dateForFirstDayInItem(2), animated: true, force: true)
            } else if indexPath.item >= self.collectionView(collectionView, numberOfItemsInSection: 0) - 2 {
                scrollToDate(dateForFirstDayInItem(self.collectionView(collectionView, numberOfItemsInSection: 0) - 3), animated: true,force: true)
            } else {
                selectedDate = dateForFirstDayInItem(indexPath.item)
            }
        }
    }

}

public class MonthPickerCollectionView: UICollectionView {

    weak var monthPickerView: MonthPickerView?

    required override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        monthPickerView?.collectionViewWillLayoutSubviews()
        super.layoutSubviews()
    }
}

private let ActiveDistance: CGFloat = 200
private let ZoomFactor: CGFloat = 0.2

public class MonthPickerCollectionViewLayout: UICollectionViewFlowLayout {

    public required override init() {
        super.init()
        scrollDirection = .Horizontal
        minimumLineSpacing = 24
        minimumInteritemSpacing = 240
        itemSize = CGSize(width: 140, height: 70)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public class func layoutAttributesClass() -> AnyClass {
        return MonthPickerCollectionViewLayoutAttributes.self
    }

    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElementsInRect(rect) as? [MonthPickerCollectionViewLayoutAttributes] else { return nil }
        guard let collectionView = collectionView else { return attributes }

        var visibleRect = CGRectNull
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size

        return attributes.map { original in
            let attributes = original.copy() as! MonthPickerCollectionViewLayoutAttributes
            if CGRectIntersectsRect(attributes.frame, rect) {
                let distance = CGRectGetMidX(visibleRect) - attributes.center.x
                let normalizedDistance = distance / ActiveDistance
                if abs(distance) < ActiveDistance {
                    let zoom = 1 + ZoomFactor * (1 - abs(normalizedDistance))
                    attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
                    attributes.zIndex = Int(round(zoom))
                    attributes.centerDistance = max(min(abs(normalizedDistance * 10), 1.0), 0.0)
                }
            }
            return attributes
        }
    }

    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }

        var offsetAdjustment: CGFloat = CGFloat(FLT_MAX)
        let horizontalCenter: CGFloat = proposedContentOffset.x + CGRectGetWidth(collectionView.bounds) / 2.0

        let targetRectHorizontal = CGRect(x: proposedContentOffset.x, y: 0.0, width: CGRectGetWidth(collectionView.bounds), height: CGRectGetHeight(collectionView.bounds))
        guard let attributes = super.layoutAttributesForElementsInRect(targetRectHorizontal) else { return proposedContentOffset }

        attributes.forEach { attributes in
            let itemHorizontalCenter = attributes.center.x
            if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }

        }

        return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y)
    }

}

class MonthPickerCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    var centerDistance: CGFloat = 1.0

    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! MonthPickerCollectionViewLayoutAttributes
        copy.centerDistance = centerDistance
        return copy
    }

    override func isEqual(object: AnyObject?) -> Bool {
        if let attributes = object as? MonthPickerCollectionViewLayoutAttributes {
            if attributes.centerDistance == centerDistance {
                return super.isEqual(object)
            }
        }
        return false
    }
}

public class MonthPickerCell: UICollectionViewCell {

    public var inactiveColor = UIColor.whiteColor()
    public var activeColor = UIColor(hexString: "#000066")

    public var date: NSDate!

    public let monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(16)
        return label
    }()

    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()

    public override var accessibilityLabel: String? {
        set {
            super.accessibilityLabel = newValue
        }
        get {
            return super.accessibilityLabel ?? "\(monthLabel.text ?? "") \(subtitleLabel.text ?? "")"
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        addSubview(monthLabel)
        addSubview(subtitleLabel)
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeZero
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 0

        isAccessibilityElement = true
    }

    public override func layoutSubviews() {
        monthLabel.sizeToFit()
        monthLabel.frame.origin = CGPoint(x: (CGRectGetWidth(bounds) - CGRectGetWidth(monthLabel.frame)) / 2, y: 12)
        subtitleLabel.sizeToFit()
        subtitleLabel.frame.origin = CGPoint(x: (CGRectGetWidth(bounds) - CGRectGetWidth(subtitleLabel.frame)) / 2, y: 40)

        super.layoutSubviews()
    }

    public override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)

        if let monthPickerCollectionViewLayoutAttributes = layoutAttributes as? MonthPickerCollectionViewLayoutAttributes {

            layer.shadowRadius = (1.0 - monthPickerCollectionViewLayoutAttributes.centerDistance) * 10
            backgroundColor = activeColor.mixWithColor(inactiveColor, weight: monthPickerCollectionViewLayoutAttributes.centerDistance)
            monthLabel.textColor = inactiveColor.mixWithColor(activeColor, weight: monthPickerCollectionViewLayoutAttributes.centerDistance)
            subtitleLabel.textColor = monthLabel.textColor
        }
    }

}