//
//  ViewController.swift
//  EasyCalendar
//
//  Created by Arturo Guerrero on 29/12/16.
//  Copyright © 2016 Mega Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CalendarViewDelegate {
    
    @IBOutlet weak var calendarView: CalendarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        calendarView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: CalendarView Delegate
    
    func calendarView(_view: CalendarView, didDragToSelectedDay day: NSDateComponents, withCalendarRange range: CalendarRange) -> CalendarRange {
        return range
    }
    
    func calendarView(_ view: CalendarView, didSelectCalendarRange calendarRange: CalendarRange) {
        print("did select range \(calendarRange.startDay.date) - \(calendarRange.endDay.date))")

    }
    


}

