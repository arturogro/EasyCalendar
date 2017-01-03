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
    
    func didDragToDay(day: NSDateComponents, selectingRange: CalendarRange, withCalendarView: CalendarView) -> CalendarRange {
        return selectingRange
    }
    
    func didSelectRange(range: CalendarRange, withCalendarView: CalendarView) {
        print("did select range \(range.startDay.date) - \(range.endDay.date))")
    }

}

