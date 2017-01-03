//
//  CalendarDayView.swift
//  SAA
//
//  Created by Arturo Guerrero on 25/11/15.
//  Copyright (c) 2015 Mega Apps. All rights reserved.
//

import UIKit

class CalendarDayView: UIView
{
     enum CalendarDayViewSelectionState {
        case CalendarDayViewNotSelected, CalendarDayViewWholeSelection, CalendarDayViewStartOfSelection, CalendarDayViewWithinSelection, CalendarDayViewEndOfSelection
    }
    
     enum CalendarDayViewPositionInWeek {
        case CalendarDayViewStartOfWeek, CalendarDayViewMidWeek, CalendarDayViewEndOfWeek
    }
    
    var inCurrentMonth: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var dayAsDate: Date!
    var calendar: NSCalendar!
    var day: NSDateComponents? {
        get {
            return self.dayAsDate.calendarViewDayWithCalendar(calendar: self.calendar)
        }
        set(newValue) {
            if newValue != nil {
                self.calendar = newValue!.calendar as NSCalendar!
                self.dayAsDate = (newValue!.date as NSDate!) as Date!
                self.day = nil
                self.labelText = "\(newValue!.day)"
            }
        }
    }
    var selectionState: CalendarDayViewSelectionState = .CalendarDayViewNotSelected {
        didSet {
            self.setNeedsDisplay()
        }

    }
    var positionInWeek: CalendarDayViewPositionInWeek!
    
    var labelText: String! = ""
    var dayNumberNotSelectedInCurrentMonthColor = UIColor(r: 74, g: 74, b: 74, alpha: 1)
    var dayNumberNotSelectedNotInCurrentMonthColor = UIColor(r: 139, g: 139, b: 139, alpha: 1)
    var backgroundNotSelectedInCurrentMonthColor = UIColor(r: 207, g: 208, b: 210, alpha: 1)
    var backgroundNotSelectedNotInCurrentMonthColor = UIColor(r: 155, g: 155, b: 155, alpha: 1)
    var dayNumberStartOfSelectionColor = UIColor(r: 207, g: 208, b: 210, alpha: 1)
    var dayNumberEndOfSelectionColor = UIColor(r: 207, g: 208, b: 210, alpha: 1)
    var dayNumberWithinSelectionColor = UIColor(r: 207, g: 208, b: 210, alpha: 1)
    var backgroundStartOfSelectionColor = UIColor(r: 239, g: 62, b: 66, alpha: 1)
    var backgroundEndOfSelectionColor = UIColor(r: 239, g: 62, b: 66, alpha: 1)
    var backgroundWithinSelectionColor = UIColor(r: 70, g: 45, b: 61, alpha: 1)
    
    //MARK: Initialization
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        positionInWeek = .CalendarDayViewMidWeek
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.white
        positionInWeek = .CalendarDayViewMidWeek
    }
    
    //MARK: UIView Methods
    
    override func draw(_ rect: CGRect)
    {
        if self.isMember(of: CalendarDayView.self) {
            // If this isn't a subclass of DSLCalendarDayView, use the default drawing
            drawBackground()
            drawBorders()
            drawDayNumber()
        }
    }
    
    //MARK: Drawing Methods
    
    func drawBackground()
    {
        if selectionState == .CalendarDayViewNotSelected {
            if inCurrentMonth {
                backgroundNotSelectedInCurrentMonthColor.setFill()
            }
            else {
                backgroundNotSelectedNotInCurrentMonthColor.setFill()
            }
            UIRectFill(bounds)
        }
        else {
            switch selectionState {
                case .CalendarDayViewNotSelected:
                    break
                case .CalendarDayViewStartOfSelection:
                    backgroundStartOfSelectionColor.setFill()
                    UIRectFill(self.bounds)
                    break
                case .CalendarDayViewEndOfSelection:
                    backgroundEndOfSelectionColor.setFill()
                    UIRectFill(self.bounds);
                    break
                case .CalendarDayViewWithinSelection:
                    backgroundWithinSelectionColor.setFill()
                    UIRectFill(self.bounds)
                    break
                case .CalendarDayViewWholeSelection:
                    break
            }
        }
    }
    
    func drawBorders() {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setLineWidth(1.0)
        context.saveGState()
        context.setStrokeColor(UIColor(white: 255.0 / 255.0, alpha: 1.0).cgColor)
        context.move(to: CGPoint(x: 0.5, y: bounds.size.height - 0.5))
        context.addLine(to: CGPoint(x: 0.5, y: 0.5))
        context.addLine(to: CGPoint(x: bounds.size.width - 0.5, y: 0.5))
        context.strokePath()
        context.restoreGState()
        context.saveGState()
        if inCurrentMonth {
            context.setStrokeColor(UIColor(white: 205.0 / 255.0, alpha: 1.0).cgColor)
        }
        else {
            context.setStrokeColor(UIColor(white: 185.0 / 255.0, alpha: 1.0).cgColor)
        }
        context.move(to: CGPoint(x: bounds.size.width - 0.5, y: 0.0))
        context.move(to: CGPoint(x:  bounds.size.width - 0.5, y: bounds.size.height - 0.5))
        context.move(to: CGPoint(x: 0.0, y: bounds.size.height - 0.5))
        context.strokePath()
        context.restoreGState()
    }
    
    func drawDayNumber()
    {
        if selectionState == .CalendarDayViewNotSelected {
            if inCurrentMonth {
                dayNumberNotSelectedInCurrentMonthColor.set()
            } else {
                dayNumberNotSelectedNotInCurrentMonthColor.set()
            }
        }
        else {
            switch (selectionState) {
                case .CalendarDayViewNotSelected:
                    break
                case .CalendarDayViewStartOfSelection:
                    dayNumberStartOfSelectionColor.set()
                    break
                case .CalendarDayViewEndOfSelection:
                    dayNumberEndOfSelectionColor.set()
                    break
                case .CalendarDayViewWithinSelection:
                    dayNumberWithinSelectionColor.set()
                    break
                case .CalendarDayViewWholeSelection:
                    break
            }
        }
        
        let attributes = [ NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17.0)]
        let textSize: CGSize = labelText.size(attributes: attributes)
        let x = ceilf(Float(bounds.midX - (textSize.width/2.0)))
        let y = ceilf(Float(bounds.midY - (textSize.height/2.0)))
        let textRect = CGRect(x: CGFloat(x), y: CGFloat(y), width: textSize.width, height: textSize.height)
        labelText.draw(in: textRect, withAttributes: attributes)
    }
}
