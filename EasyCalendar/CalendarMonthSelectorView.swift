//
//  CalendarMonthSelectorView.swift
//  SAA
//
//  Created by Arturo Guerrero on 25/11/15.
//  Copyright (c) 2015 Mega Apps. All rights reserved.
//

import UIKit

protocol CalendarMonthSelectorViewDelegate {
    func didTapMonthBack()
    func didTapMonthForward()
}
class CalendarMonthSelectorView: UIView
{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet var dayLabels: [UILabel]!
    
    var delegate: CalendarMonthSelectorViewDelegate?
    
    class func instanceFromNib() -> CalendarMonthSelectorView {
        return UINib(nibName: "CalendarMonthSelector", bundle: nil).instantiate(withOwner: nil, options: nil).last as! CalendarMonthSelectorView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Get a dictionary of localised day names
        var dateComponents: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day, .weekday, .calendar], from: NSDate() as Date)
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "EEE"
        var dayNames = [Int : AnyObject]()
        for _ in 0 ..< 7 {
            var weekday: Int = dateComponents.weekday! - dateComponents.calendar!.firstWeekday
            if weekday < 0 {
                weekday += 7
            }
            dayNames[weekday] = formatter.string(from: dateComponents.date!) as AnyObject?
            dateComponents.day = dateComponents.day! + 1
            dateComponents = dateComponents.calendar!.dateComponents([.year, .month, .day, .weekday, .calendar], from: dateComponents.date!)
        }
        // Set the day name label texts to localised day names
        for label: UILabel in dayLabels {
            label.text = dayNames[label.tag]!.uppercased
        }
    }
    
    @IBAction func didPressBackButton(_ sender: Any) {
        delegate?.didTapMonthBack()
    }
    
    @IBAction func didPressForwardButton(_ sender: Any) {
        delegate?.didTapMonthForward()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

