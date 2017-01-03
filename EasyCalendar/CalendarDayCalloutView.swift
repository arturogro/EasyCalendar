//
//  CalendarDayCalloutView.swift
//  SAA
//
//  Created by Arturo Guerrero on 25/11/15.
//  Copyright (c) 2015 Mega Apps. All rights reserved.
//

import UIKit

class CalendarDayCalloutView: UIView {
    
    var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    class func instanceFromNib() -> CalendarDayCalloutView {
        return UINib(nibName: "CalendarDayCalloutView", bundle: nil).instantiate(withOwner: nil, options: nil).last as! CalendarDayCalloutView
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func configureForDay(day: NSDateComponents)
    {
        if imageView == nil {
            let calloutImage: UIImage = UIImage(named: "CalendarDayCallout")!
            self.imageView = UIImageView(image: calloutImage.resizableImage(withCapInsets: UIEdgeInsetsMake(14.0, 36.0, 60.0, 36.0)))
            self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.imageView.frame = bounds
            insertSubview(imageView, at: 0)
        }
        self.titleLabel.text = "\(day.day)"
        self.titleLabel.textAlignment = .center
        let imagePadding: CGFloat = 15.0
        var frame: CGRect = self.frame
        frame.origin.x -= imagePadding
        frame.size.width += 2 * imagePadding
        let imageHeight: CGFloat = 99.0
        if frame.size.height < imageHeight {
            frame.origin.y -= imageHeight - frame.size.height
            frame.size.height = imageHeight
        }
        self.frame = frame
        
        self.layoutIfNeeded()
    }
}
