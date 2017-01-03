//
//  CalendarRange.swift
//  SAA
//
//  Created by Arturo Guerrero on 25/11/15.
//  Copyright (c) 2015 Mega Apps. All rights reserved.
//

import UIKit

class CalendarRange : NSObject
{
    var startDay: NSDateComponents!
    var endDay: NSDateComponents!
    
    var startDate: NSDate!
    var endDate: NSDate!
    
    init(startDay: NSDateComponents, endDay: NSDateComponents)
    {
        self.startDate = startDay.date as NSDate!
        self.endDate = endDay.date as NSDate!
        self.startDay = startDay
        self.endDay = endDay
    }
    
    //MARK: Helper Methods
    
    func containsDay(day: NSDateComponents) -> Bool {
        return containsDate(date: day.date! as NSDate)
    }
    
    func containsDate(date: NSDate) -> Bool
    {
        if startDate.compare(date as Date) == .orderedDescending {
            return false
        }
        else if endDate.compare(date as Date) == .orderedAscending {
            return false
        }
        return true
    }
}
