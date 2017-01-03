# EasyCalendar

EasyCalendar is an iOS control written in Swift 3 that displays a calendar similar to the system calendar. <br /><br />
With this control you can select a single date or a date range. <br />

## Usage
1. Import the EasyCalendar folder and all images in your existing project.
2. Connect your `CalendarView` to your View Controller.

  ```swift
  @IBOutlet weak var calendarView: CalendarView!
  ```
3. Conform your View Controler with `CalendarViewDelegate` protocol, and set the delegate.

  ```swift
    calendarView.delegate = self
  ```
4. Implement the protocol methods that you need for your project.

## Preview
<img src="http://i.imgur.com/T6WEsPU.png" width="269" height="479" />

##License
MIT
