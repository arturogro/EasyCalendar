//
//  CalendarMonthView.swift
//  SAA
//
//  Created by Arturo Guerrero on 25/11/15.
//  Copyright (c) 2015 Mega Apps. All rights reserved.
//

import UIKit

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

class CalendarMonthView: UIView {
    
    var month: NSDateComponents!
    var dayViewHeight: CGFloat!
    var dayViewsDictionary: [String: CalendarDayView]!
    var dayViewClass: AnyClass!
    var dayViews: Set<CalendarDayView>! {
        get {
           return Set(dayViewsDictionary.values)
        }
        set {
            self.dayViews = newValue
        }
    }
    
    init(month: NSDateComponents, width: CGFloat, dayViewClass: AnyClass, dayViewHeight: CGFloat)
    {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: dayViewHeight))
        self.month = month
        self.dayViewHeight = dayViewHeight
        self.dayViewClass = dayViewClass
        self.dayViewsDictionary = [String: CalendarDayView]()
        self.createDayViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createDayViews()
    {
        let numberOfDaysPerWeek: Int = 7
        var day: NSDateComponents = NSDateComponents()
        day.calendar = month.calendar
        day.day = 1
        day.month = month.month
        day.year = month.year
        //var firstDate: NSDate = day.calendar!.dateFromComponents(day)!
        let firstDate = Calendar.current.date(from: month as DateComponents)
        day = firstDate!.calendarViewDayWithCalendar(calendar: month.calendar! as NSCalendar)
        
        let numberOfDaysInMonth: Int = (Calendar.current.range(of: .day, in: .month, for: day.date!)?.count)!
        var startColumn: Int = day.weekday - day.calendar!.firstWeekday
        if startColumn < 0 {
            startColumn += numberOfDaysPerWeek
        }
        var columnWidths: [CGFloat] = calculateColumnWidthsForColumnCount(columnCount: numberOfDaysPerWeek)
        var nextDayViewOrigin: CGPoint = CGPoint.zero
        for column in 0 ..< startColumn {
            nextDayViewOrigin.x += CGFloat(columnWidths[column])
        }
        repeat {
            for column in startColumn ..< numberOfDaysPerWeek {
                if day.month == month.month {
                    var dayFrame: CGRect = CGRect.zero
                    dayFrame.origin = nextDayViewOrigin
                    dayFrame.size.width = CGFloat(columnWidths[column])
                    dayFrame.size.height = dayViewHeight
                    
                    let dayView: CalendarDayView = CalendarDayView(frame: dayFrame)
                    dayView.day = day
                    switch column {
                    case 0:
                        dayView.positionInWeek = .CalendarDayViewStartOfWeek
                    case numberOfDaysPerWeek - 1:
                        dayView.positionInWeek = .CalendarDayViewEndOfWeek
                    default:
                        dayView.positionInWeek = .CalendarDayViewMidWeek
                    }
                    dayViewsDictionary[dayViewKeyForDay(day: day)] = dayView
                    dayView.clipsToBounds = true
                    self.addSubview(dayView)
                    dayView.setNeedsLayout()
                    dayView.layoutIfNeeded()
                }
                day.day = day.day + 1
                nextDayViewOrigin.x += CGFloat(columnWidths[column])
            }
            nextDayViewOrigin.x = 0
            nextDayViewOrigin.y += dayViewHeight
            startColumn = 0
        } while day.day <= numberOfDaysInMonth
        var fullFrame: CGRect = CGRect.zero
        fullFrame.size.height = nextDayViewOrigin.y
        for width in columnWidths {
            fullFrame.size.width += width
        }
        self.frame = fullFrame
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func updateDaySelectionStatesForRange(range: CalendarRange?)
    {
        for dayView: CalendarDayView in dayViews {
            if let range = range {
                if range.containsDate(date: dayView.dayAsDate as NSDate) {
                    let isStartOfRange: Bool = range.startDay.isEqual(dayView.day)
                    let isEndOfRange: Bool = range.endDay.isEqual(dayView.day)
                    if isStartOfRange && isEndOfRange {
                        dayView.selectionState = .CalendarDayViewWholeSelection
                    } else if isStartOfRange {
                        dayView.selectionState = .CalendarDayViewStartOfSelection
                    } else if isEndOfRange {
                        dayView.selectionState = .CalendarDayViewEndOfSelection
                    } else {
                        dayView.selectionState = .CalendarDayViewWithinSelection
                    }
                } else {
                    dayView.selectionState = .CalendarDayViewNotSelected
                }
            }
        }
    }
    
    func calculateColumnWidthsForColumnCount(columnCount: Int) -> [CGFloat]
    {
        var widthsCache: NSCache<AnyObject, AnyObject>?
        let _onceToken = NSUUID().uuidString
        
        DispatchQueue.once(token: _onceToken) {
            widthsCache = NSCache()
        }
        var columnWidths = widthsCache?.object(forKey: columnCount as AnyObject) as? [CGFloat]
        if columnWidths == nil {
            let width: CGFloat = floor(bounds.size.width / CGFloat(columnCount))
            columnWidths = Array<CGFloat>(repeating: CGFloat(), count: columnCount)
            for _ in 0 ..< columnCount {
                columnWidths?.append(width)
            }
            var remainder: CGFloat = self.bounds.size.width - (width * CGFloat(columnCount))
            var padding: CGFloat = 1
            if remainder > CGFloat(columnCount) {
                padding = ceil(remainder / CGFloat(columnCount))
            }
            for column in 0 ..< columnCount {
                columnWidths![column] = width + padding
                remainder -= padding
                if remainder < 1 {
                    
                }
            }
            widthsCache!.setObject(columnWidths! as AnyObject, forKey: columnCount as AnyObject)
        }
        return columnWidths!
    }
    
    //MARK: Properties
    
    func dayViewKeyForDay(day: NSDateComponents) -> String
    {
        var formatter: DateFormatter!
        let _onceToken = NSUUID().uuidString
        
        DispatchQueue.once(token: _onceToken) {
            formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        }
        return formatter.string(from: day.date!)
    }
    
}
