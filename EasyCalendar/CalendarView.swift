//
//  CalendarView.swift
//  SAA
//
//  Created by Arturo Guerrero on 24/11/15.
//  Copyright (c) 2015 Mega Apps. All rights reserved.
//

import UIKit

@objc protocol CalendarViewDelegate: NSObjectProtocol {
    @objc optional func didSelectRange(range: CalendarRange, withCalendarView: CalendarView) -> Void
    @objc optional func willChangeToVisibleMonth(month: NSDateComponents, duration: TimeInterval, withCalendarView: CalendarView) -> Void
    @objc optional func didChangeToVisibleMonth(month: NSDateComponents, withCalendarView: CalendarView) -> Void
    @objc optional func didDragToDay(day: NSDateComponents, selectingRange: CalendarRange, withCalendarView: CalendarView) -> CalendarRange
    @objc optional func shouldAnimateDragToMonth(month: NSDateComponents, withCalendarView: CalendarView) -> Bool
}
class CalendarView : UIView, CalendarMonthSelectorViewDelegate {
    
    var visibleMonthComponents: NSDateComponents!
    var showDayCalloutView: Bool = false

    lazy var monthSelectorView: CalendarMonthSelectorView! = CalendarMonthSelectorView.instanceFromNib()
    lazy var dayCalloutView: CalendarDayCalloutView! = CalendarDayCalloutView.instanceFromNib()
    
    var selectedRange: CalendarRange? {
        didSet {
            for (_, monthView) in monthViews {
                monthView.updateDaySelectionStatesForRange(range: selectedRange)
            }
        }
    }
    
    var delegate: CalendarViewDelegate!
    
    var monthContainerViewContentView: UIView!
    var monthContainerView: UIView!
    
    var draggingStartDayComponents: NSDateComponents! {
        didSet {
            if draggingStartDayComponents == nil {
                dayCalloutView.removeFromSuperview()
            }
        }
    }
    var draggingFixedDayComponents: NSDateComponents!
    var draggedOffStartDay: Bool = false
    
    var dayViewHeight: CGFloat!
    
    var monthViews = [String : CalendarMonthView]()
    
    //MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView()
    {
        dayViewHeight = 44
        visibleMonthComponents = NSCalendar.current.dateComponents([.year, .month, .day, .weekday, .calendar], from: NSDate() as Date) as NSDateComponents!
        visibleMonthComponents.day = 1
        showDayCalloutView = true
        var monthSelectorFrame = self.bounds
        monthSelectorFrame.size.height = monthSelectorView.bounds.size.height
        monthSelectorView.backgroundColor = UIColor.clear
        monthSelectorView.frame = monthSelectorFrame
        monthSelectorView.delegate = self
        monthSelectorView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        self.addSubview(monthSelectorView)
        
        // Month views are contained in a content view inside a container view - like a scroll view, but not a scroll view so we can have proper control over animations
        var frame = self.bounds
        frame.origin.x = 0
        frame.origin.y = monthSelectorView.frame.maxY
        frame.size.height -= frame.origin.y
        
        monthContainerView = UIView(frame: frame)
        monthContainerView.clipsToBounds = true
        self.addSubview(monthContainerView)
        
        monthContainerViewContentView = UIView(frame: monthContainerView.frame)
        monthContainerView.addSubview(monthContainerViewContentView)
        
        updateMonthLabelMonth(month: visibleMonthComponents)
        positionViewsForMonth(month: visibleMonthComponents, fromMonth: visibleMonthComponents, animated: false)
   }
    
    //MARK: Utility Methods
    
    func setVisibleMonth(visibleMonth: NSDateComponents) -> Void
    {
        setVisibleMonth(visibleMonth: visibleMonth, animated: false)
    }
    
    func setVisibleMonth(visibleMonth: NSDateComponents, animated: Bool)
    {
        let fromMonth: NSDateComponents = visibleMonth
        self.visibleMonthComponents = visibleMonth.date!.calendarViewMonthWithCalendar(calendar: visibleMonth.calendar! as NSCalendar)
        updateMonthLabelMonth(month: visibleMonth)
        positionViewsForMonth(month: visibleMonth, fromMonth: fromMonth, animated: animated)
    }
    
    //MARK: Interface Actions
    
    func didTapMonthBack()
    {
        let newMonth: NSDateComponents = visibleMonthComponents
        newMonth.month -= 1
        setVisibleMonth(visibleMonth: newMonth, animated: true)
    }
    
    func didTapMonthForward()
    {
        let newMonth: NSDateComponents = visibleMonthComponents
        newMonth.month += 1
        setVisibleMonth(visibleMonth: newMonth, animated: true)
    }
    
    //MARK: Helper Methods
    
    func updateMonthLabelMonth(month: NSDateComponents)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let date = Calendar.current.date(from: month as DateComponents)
        monthSelectorView.titleLabel.text = formatter.string(from: date!)
    }
    
    func positionViewsForMonth(month: NSDateComponents, fromMonth: NSDateComponents, animated: Bool)
    {
        var nextVerticalPosition: CGFloat = 0.0
        var startingVerticalPostion: CGFloat  = 0.0
        var restingVerticalPosition: CGFloat  = 0.0
        var restingHeight: CGFloat = 0.0
        
        let monthComparisonResult: ComparisonResult = month.date!.compare(fromMonth.date!)
        let animationDuration: TimeInterval = (monthComparisonResult == .orderedSame || !animated) ? 0.0 : 0.5
        
        var activeMonthViews = [CalendarMonthView]()
        
        // Create and position the month views for the target month and those around it
        for monthOffset in -2...2 {
            var offsetMonth = month.copy() as! NSDateComponents
            offsetMonth.month = offsetMonth.month + monthOffset
            offsetMonth = offsetMonth.calendar!.dateComponents([.year, .month, .day, .weekday, .calendar], from: offsetMonth.date!) as NSDateComponents
            
            // Check if this month should overlap the previous month
            if !monthStartsOnFirstDayOfWeek(month: offsetMonth) {
                nextVerticalPosition -= dayViewHeight
            }
            
            // Create and position the month view
            let monthView: CalendarMonthView = cachedOrCreatedMonthViewForMonth(month: offsetMonth)
            activeMonthViews.append(monthView)
            monthView.superview!.bringSubview(toFront: monthView)
            
            var frame: CGRect = monthView.frame
            frame.origin.y = nextVerticalPosition
            nextVerticalPosition += frame.size.height
            monthView.frame = frame
            monthView.setNeedsLayout()
            monthView.layoutIfNeeded()
            
            if monthOffset == 0 {
                restingVerticalPosition = monthView.frame.origin.y
                restingHeight += monthView.bounds.size.height
            }
            else {
                if monthOffset == 1 && monthComparisonResult == .orderedAscending {
                    startingVerticalPostion = monthView.frame.origin.y
                    if monthStartsOnFirstDayOfWeek(month: offsetMonth) {
                        startingVerticalPostion -= dayViewHeight
                    }
                }
                else {
                    if monthOffset == -1 && monthComparisonResult == .orderedDescending {
                        startingVerticalPostion = monthView.frame.origin.y
                        if monthStartsOnFirstDayOfWeek(month: offsetMonth) {
                            startingVerticalPostion -= dayViewHeight
                        }
                    }
                }
            }
            
            if monthOffset == 0 && monthStartsOnFirstDayOfWeek(month: offsetMonth) {
                restingVerticalPosition -= dayViewHeight
                restingHeight += dayViewHeight
            }
            else {
                if monthOffset == 1 && monthStartsOnFirstDayOfWeek(month: offsetMonth) {
                    restingHeight += dayViewHeight
                }
            }

        }
        
        var frame: CGRect = monthContainerViewContentView.frame
        frame.size.height = activeMonthViews.last!.frame.maxY
        self.monthContainerViewContentView.frame = frame
        let monthViewKeyes = monthViews.keys
        for key: String in monthViewKeyes {
            let monthView: CalendarMonthView = monthViews[key]!
            if !activeMonthViews.contains(monthView) {
                monthView.removeFromSuperview()
                monthViews.removeValue(forKey: key)
            }
        }
        if monthComparisonResult != .orderedSame {
            var frame: CGRect = monthContainerViewContentView.frame
            frame.origin.y = -startingVerticalPostion
            self.monthContainerViewContentView.frame = frame
        }
        self.isUserInteractionEnabled = false

        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut, animations: {() -> Void in
            for index in 0 ..< activeMonthViews.count {
                
                let monthView: CalendarMonthView = activeMonthViews[activeMonthViews.startIndex.advanced(by: index)]
                let inCurrentMonth = (index == 2) ? true : false
                for dayView: CalendarDayView in monthView.dayViews {
                    UIView.transition(with: dayView, duration: animationDuration, options: .transitionCrossDissolve, animations: {() -> Void in
                        dayView.inCurrentMonth = inCurrentMonth
                        }, completion: nil)
                }
            }
            
            var frame: CGRect = self.monthContainerViewContentView.frame
            frame.origin.y = -restingVerticalPosition
            self.monthContainerViewContentView.frame = frame
            frame = self.monthContainerView.frame
            
            frame.size.height = restingHeight
            self.monthContainerView.frame = frame
            frame.size.height = self.monthContainerView.frame.maxY
            self.frame = frame
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            if monthComparisonResult != .orderedSame && self.delegate.responds(to: #selector(CalendarViewDelegate.willChangeToVisibleMonth(month:duration:withCalendarView:))) {
                self.delegate.willChangeToVisibleMonth!(month: month, duration: animationDuration, withCalendarView: self)
            }
            }, completion: {(finished: Bool) -> Void in
                self.isUserInteractionEnabled = true
                if finished {
                    if monthComparisonResult != .orderedSame && self.delegate.responds(to: #selector(CalendarViewDelegate.didChangeToVisibleMonth(month:withCalendarView:))) {
                        self.delegate.didChangeToVisibleMonth!(month: month, withCalendarView: self)
                    }
                }
        })
    }
    
    func monthViewKeyForMonth(month: NSDateComponents) -> String
    {
        var month = Calendar.current.dateComponents([.year, .month], from: month.date!)
        return "\(month.year).\(month.month)"
    }
    
    func monthStartsOnFirstDayOfWeek(month: NSDateComponents) -> Bool
    {
        // Make sure we have the components we need to do the calculation
        var month = Calendar.current.dateComponents([.year, .month, .day, .weekday, .calendar], from: month.date!)
        
        return (month.weekday! - month.calendar!.firstWeekday) == 0
    }
    
    func cachedOrCreatedMonthViewForMonth(month: NSDateComponents) -> CalendarMonthView
    {
        let month = Calendar.current.dateComponents([.year, .month, .day, .weekday, .calendar], from: month.date!)
        
        let monthViewKey: String = monthViewKeyForMonth(month: month as NSDateComponents)
        var monthView = monthViews[monthViewKey]
        if monthView == nil {
            monthView = CalendarMonthView(month: month as NSDateComponents, width: bounds.size.width, dayViewClass: CalendarDayView.classForCoder(), dayViewHeight: dayViewHeight)
            monthViews[monthViewKey] = monthView
            monthContainerViewContentView.addSubview(monthView!)
            monthView!.updateDaySelectionStatesForRange(range: selectedRange)
        }
        return monthView!
    }
    
    //MARK: Touch Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touchedView: CalendarDayView? = dayViewForTouches(touches: touches)
        if touchedView == nil {
            self.draggingStartDayComponents = nil
            return
        }
        self.draggingStartDayComponents = touchedView!.day
        self.draggingFixedDayComponents = touchedView!.day
        self.draggedOffStartDay = false
        var newRange: CalendarRange? = selectedRange
        
        if let selectedRange = selectedRange {
            if !selectedRange.startDay.isEqual(touchedView!.day) && !selectedRange.endDay.isEqual(touchedView!.day) {
                newRange = CalendarRange(startDay: touchedView!.day!, endDay: touchedView!.day!)
            }
            else if selectedRange.startDay.isEqual(touchedView!.day) {
                self.draggingFixedDayComponents = selectedRange.endDay
            } else {
                self.draggingFixedDayComponents = selectedRange.startDay
            }
        } else {
            newRange = CalendarRange(startDay: touchedView!.day!, endDay: touchedView!.day!)
        }
        if delegate.responds(to: #selector(CalendarViewDelegate.didDragToDay(day:selectingRange:withCalendarView:))) {
            if let range = newRange {
                newRange = delegate.didDragToDay!(day: touchedView!.day!, selectingRange: range, withCalendarView: self)
            }
        }
        self.selectedRange = newRange
        self.positionCaloutViewForDayView(dayView: touchedView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if draggingStartDayComponents == nil {
            return
        }
        let touchedView: CalendarDayView? = dayViewForTouches(touches: touches)
        if touchedView == nil {
            self.draggingStartDayComponents = nil
            return
        }
        var newRange: CalendarRange
        if touchedView!.day!.date!.compare(draggingFixedDayComponents.date!) == .orderedAscending {
            newRange = CalendarRange(startDay: touchedView!.day!, endDay: self.draggingFixedDayComponents)
        }
        else {
            newRange = CalendarRange(startDay:self.draggingFixedDayComponents, endDay: touchedView!.day!)
        }
        if delegate.responds(to: #selector(CalendarViewDelegate.didDragToDay(day:selectingRange:withCalendarView:))) {
            newRange = delegate.didDragToDay!(day: touchedView!.day!, selectingRange: newRange, withCalendarView: self)
        }
        self.selectedRange = newRange
        if !draggedOffStartDay {
            if !draggingStartDayComponents.isEqual(touchedView!.day) {
                self.draggedOffStartDay = true
            }
        }
        self.positionCaloutViewForDayView(dayView: touchedView)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if draggingStartDayComponents == nil {
            return
        }
        let touchedView: CalendarDayView? = dayViewForTouches(touches: touches)
        if touchedView == nil {
            self.draggingStartDayComponents = nil
            return
        }
        if !draggedOffStartDay && draggingStartDayComponents.isEqual(touchedView!.day) {
            self.selectedRange = CalendarRange(startDay: touchedView!.day!, endDay: touchedView!.day!)
        }
        self.draggingStartDayComponents = nil
        // Check if the user has dragged to a day in an adjacent month
        if touchedView!.day!.year != visibleMonthComponents.year || touchedView!.day!.month != visibleMonthComponents.month {
            // Ask the delegate if it's OK to animate to the adjacent month
            var animateToAdjacentMonth: Bool = true

            if delegate.responds(to: #selector(CalendarViewDelegate.shouldAnimateDragToMonth(month:withCalendarView:))) {
                animateToAdjacentMonth = delegate.shouldAnimateDragToMonth!(month: touchedView!.dayAsDate.calendarViewMonthWithCalendar(calendar: visibleMonthComponents.calendar! as NSCalendar), withCalendarView: self)
            }
            if animateToAdjacentMonth {
                
                if touchedView!.dayAsDate.compare(visibleMonthComponents.date!) == .orderedAscending {
                    self.didTapMonthBack()
                }
                else {
                    self.didTapMonthForward()
                }
            }
        }
        if self.delegate.responds(to: #selector(CalendarViewDelegate.didSelectRange(range:withCalendarView:))) {
            if let range = selectedRange {
                delegate.didSelectRange!(range: range, withCalendarView: self)
            }
        }
    }
    
    func dayViewForTouches(touches: Set<NSObject>) -> CalendarDayView?
    {
        if touches.count != 1 {
            return nil
        }
        let touch: UITouch = (touches.first as? UITouch)!
        // Check if the touch is within the month container
        if !monthContainerView.frame.contains(touch.location(in: monthContainerView.superview)) {
            return nil
        }
        // Work out which day view was touched. We can't just use hit test on a root view because the month views can overlap
        for (_, monthView) in monthViews  {
            var view: UIView? = monthView.hitTest(touch.location(in: monthView), with: nil)
            if view == nil {
                continue
            }
            while view != monthView {
                if view!.isKind(of: CalendarDayView.self) {
                    return view as? CalendarDayView
                }
                view = view!.superview
            }
        }
        return nil
    }
    
    
    //MARK: CalendarDayCalloutView Methods
    
    func positionCaloutViewForDayView(dayView: CalendarDayView?) {
        if dayView == nil {
            if dayCalloutView != nil {
                dayCalloutView?.removeFromSuperview()
            }
        } else if showDayCalloutView {
            var calloutFrame = convert(dayView!.frame, from: dayView?.superview)
            calloutFrame.origin.y -= calloutFrame.size.height
            calloutFrame.size.height *= 2
            
            dayCalloutView.frame = calloutFrame
            dayCalloutView.configureForDay(day: dayView!.day!)
            
            if dayCalloutView.superview == nil {
                self.addSubview(dayCalloutView)
            } else {
                self.bringSubview(toFront: dayCalloutView)
            }
        }
    }
}

extension Date {
    func calendarViewDayWithCalendar(calendar: NSCalendar) -> NSDateComponents {
        return calendar.components([.calendar, .year, .month, .day, .weekday], from: self) as NSDateComponents
    }
    
    func calendarViewMonthWithCalendar(calendar: NSCalendar) -> NSDateComponents {
        return calendar.components([.calendar, .year, .month], from: self) as NSDateComponents
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
}
