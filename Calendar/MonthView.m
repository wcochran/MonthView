//
//  MonthView.m
//  Calendar
//
//  Created by Wayne Cochran on 2/9/14.
//  Copyright (c) 2014 Wayne Cochran. All rights reserved.
//

#import "MonthView.h"
#include <math.h>

@interface MonthView ()

-(CGRect)contentRect;
-(void)installTapGestureRecognizer;
-(void)fetchMonthInfo;

@end

@implementation MonthView {
    NSString *_monthYearString;
    
    NSInteger _month;
    NSInteger _year;
    NSInteger _startDayOfWeek;
    NSInteger _numberOfDays;
    NSInteger _numberOfDaysInPreviousMonth;
    
    NSInteger _selectedDay;
    NSInteger _selectedMonth;
    NSInteger _selectedYear;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self installTapGestureRecognizer];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self installTapGestureRecognizer];
    }
    return self;
}

//
// The Calender is laid out on a 7x7 grid inside the 'contentRect' within the view.
// Only the bottom 6 rows represent 6x7 = 42 selectable days.
//
-(void)handleTap:(UITapGestureRecognizer*)tapGestureRecognizer {
    const CGPoint tapPoint = [tapGestureRecognizer locationInView:self];
    const CGRect contentRect = [self contentRect];
    const CGSize gridSquareSize = CGSizeMake(contentRect.size.width/7, contentRect.size.height/7);
    const int row = floor((tapPoint.y - contentRect.origin.y)/gridSquareSize.height);
    const int col = floor((tapPoint.x - contentRect.origin.x)/gridSquareSize.width);
    
    if (row <= 0 || row > 6 || col < 0 || col > 6)
        return;
    
    const int N = 7*(row-1) + col - _startDayOfWeek + 1;
    if (N < 0) {
        if (_month == 1) {
            _selectedMonth = 12;
            _selectedYear = _year - 1;
        } else {
            _selectedMonth = _month - 1;
            _selectedYear = _year;
        }
        _selectedDay = _numberOfDaysInPreviousMonth + N + 1;
    } else if (N >= _numberOfDays) {
        if (_month == 12) {
            _selectedMonth = 1;
            _selectedYear = _year + 1;
        } else {
            _selectedMonth = _month + 1;
            _selectedYear = _year;
        }
        _selectedDay = N - _numberOfDays + 1;
    } else {
        _selectedMonth = _month;
        _selectedYear = _year;
        _selectedDay = N + 1;
    }
    NSLog(@"selected year/month/day = %d/%d/%d", _selectedYear, _selectedMonth, _selectedDay);
    
}

-(void)installTapGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
}

-(void)fetchMonthInfo {
    //NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //
    // Get weekday (1 => Sunday, ..., 7 => Saturday) for the first day of month
    // specified by 'self.date'.
    //
    NSDateComponents *dateComponents  = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                    fromDate:self.date];
    dateComponents.day = 1;
    NSDate *firstDayOfMonth = [calendar dateFromComponents:dateComponents];
    dateComponents = [calendar components:(NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                 fromDate:firstDayOfMonth];
    _startDayOfWeek = [dateComponents weekday];
    
    
    //
    // Get number of days in previous month.
    //
    _year = [dateComponents year];
    _month = [dateComponents month];
    const NSInteger previousMonthNum = (_month == 1) ? 12 : (_month - 1);
    const NSInteger previousMonthYear = (previousMonthNum == 12) ? _year - 1 : _year;
    dateComponents.month = previousMonthNum;
    dateComponents.year = previousMonthYear;
    NSDate *previousMonth = [calendar dateFromComponents:dateComponents];
    NSRange previousMonthDays = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:previousMonth];
    _numberOfDaysInPreviousMonth = previousMonthDays.length;
    
    
    //
    // Get number of days in month containing 'self.date'.
    //
    NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit
                                  inUnit:NSMonthCalendarUnit
                                 forDate:self.date];
    _numberOfDays = days.length;
    
    
    //
    // Get Header string for Month, Year containing 'self.date'.
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM YYYY";
    _monthYearString = [dateFormatter stringFromDate:self.date];
}

#define MARGIN 2

-(CGRect)contentRect {
    const CGFloat size = MIN(self.bounds.size.width,self.bounds.size.height) - MARGIN;
    const CGRect contentRect = CGRectMake((self.bounds.size.width - size)/2,
                                          (self.bounds.size.height - size)/2,
                                          size, size);
    return contentRect;
}

//
// Draws month in largest possible square centered in view.
// Month is laid on on a 7x7 grid; the top row contains Month/Year title
// and 7 column headers for the for the days of the week.
// The last 6 rows (bottom 6x7 portion of the grid) contains 42 days
// which covers the month specified in 'self.date' as well as 0 to 6 days
// of the previous month and as many days of the next month fill in
// the last 1 or 2 rows.
// We assume the drawing region is a 700x700 square and modify the
// Current Modeling Transformation (CTM) to map this to a square that
// fite comfortable winthin the view.
//
- (void)drawRect:(CGRect)rect
{
    //
    // Make sure 'self.date' is set to something.
    //
    if (self.date == nil) {
        self.date = [NSDate date];
        [self fetchMonthInfo];
    }
    
    //
    // Lazily fetch month info need for rendering.
    //
    if (_monthYearString == nil)
        [self fetchMonthInfo];
    
//    NSLog(@"month start day of week = %d", self.startDayOfWeek);
//    NSLog(@"number of days in month = %d", self.numberOfDays);
//    NSLog(@"month ='%@'", self.monthYearString);
//    NSLog(@"previous month days = %d", self.numberOfDaysInPreviousMonth);
    
    //
    // Use Core Graphics to render month view.
    //
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //
    // Find the largest square that can fit in the current view and
    // center it.
    // Modify the CTM so that our 700 x 700 drawing maps to this square.
    //
    const CGFloat size = MIN(self.bounds.size.width,self.bounds.size.height) - MARGIN;
    const CGRect contentRect = [self contentRect];
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, contentRect.origin.x, contentRect.origin.y);
    CGContextScaleCTM(context, size/700, size/700);
    
    //
    // Construct text attributes used to render title, days of the week, and days.
    //
    //UIFont *font = [UIFont boldSystemFontOfSize:30];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:30];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: [UIColor blackColor],
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    //
    // Draw Month/Year title.
    //
    const CGSize headTextSize = [_monthYearString sizeWithAttributes:attributes];
    const CGRect headRect = CGRectMake((700 - headTextSize.width)/2, (50 - headTextSize.height)/2,
                                       headTextSize.width, headTextSize.height);
    [_monthYearString drawInRect:headRect withAttributes:attributes];
    
    //
    // Draw days of week.
    //
    NSArray *dowStrings = @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"];
    for (int c = 0; c < 7; c++) {
        NSString *dow = [dowStrings objectAtIndex:c];
        const CGSize dowSize = [dow sizeWithAttributes:attributes];
        const CGRect dowRect = CGRectMake(c*100 + (100 - dowSize.width)/2, 50 + (50 - dowSize.height),
                                          dowSize.width, dowSize.height);
        [dow drawInRect:dowRect withAttributes:attributes];
    }
    
    //
    // Draw background 7x6 grid to holds month days.
    //
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextSetLineWidth(context, 0.5);
    for (int r = 1; r < 8; r++) {
        CGContextMoveToPoint(context, 0, r*100);
        CGContextAddLineToPoint(context, 700, r*100);
        CGContextStrokePath(context);
    }
    for (int c = 0; c < 8; c++) {
        CGContextMoveToPoint(context, c*100, 100);
        CGContextAddLineToPoint(context, c*100, 700);
        CGContextStrokePath(context);
    }
    
    //
    // Draw numbers and boxes for days of current month.
    //
    CGContextSetLineWidth(context, 4);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    int r = 1;
    int c = _startDayOfWeek - 1;
    for (int d = 1; d <= _numberOfDays; d++) {
        const CGRect monthRect = CGRectMake(c*100, r*100, 100, 100);
        CGContextStrokeRect(context, monthRect);
        NSString *dayStr = [NSString stringWithFormat:@"%d", d];
        const CGSize dsize = [dayStr sizeWithAttributes:attributes];
        const CGRect drect = CGRectMake(monthRect.origin.x + (50 - dsize.width)/2,
                                        monthRect.origin.y + (50 - dsize.height)/2,
                                        dsize.width, dsize.height);
        [dayStr drawInRect:drect withAttributes:attributes];
        if (c == 6) {
            c = 0;
            r++;
        } else {
            c++;
        }
    }
    
    //
    // Pick light attributes to be used for drawing days of previous
    // and next month.
    //
    NSDictionary *lightAttributes = @{ NSFontAttributeName: font,
                                       NSForegroundColorAttributeName: [UIColor grayColor],
                                       NSParagraphStyleAttributeName: paragraphStyle };
    //
    // Draw days of previous month.
    //
    if (_startDayOfWeek > 1) {
        const int n = _startDayOfWeek - 1;
        int day = _numberOfDaysInPreviousMonth - n + 1;
        for (int c = 0; c < n; c++) {
            const CGRect monthRect = CGRectMake(c*100, 100, 100, 100);
            NSString *dayStr = [NSString stringWithFormat:@"%d", day];
            const CGSize dsize = [dayStr sizeWithAttributes:lightAttributes];
            const CGRect drect = CGRectMake(monthRect.origin.x + (50 - dsize.width)/2,
                                            monthRect.origin.y + (50 - dsize.height)/2,
                                            dsize.width, dsize.height);
            [dayStr drawInRect:drect withAttributes:lightAttributes];
            day++;
        }
    }
    
    //
    // Draw days of next month.
    //
    const int daysCovered = _numberOfDays + _startDayOfWeek - 1;
    const int daysLeft = 7*6 - daysCovered;
    c = daysCovered % 7;
    r = daysCovered / 7 + 1;
    for (int day = 1; day <= daysLeft; day++) {
        const CGRect monthRect = CGRectMake(c*100, r*100, 100, 100);
        NSString *dayStr = [NSString stringWithFormat:@"%d", day];
        const CGSize dsize = [dayStr sizeWithAttributes:lightAttributes];
        const CGRect drect = CGRectMake(monthRect.origin.x + (50 - dsize.width)/2,
                                        monthRect.origin.y + (50 - dsize.height)/2,
                                        dsize.width, dsize.height);
        [dayStr drawInRect:drect withAttributes:lightAttributes];
        if (c == 6) {
            c = 0;
            r++;
        } else {
            c++;
        }
    }
    
    //
    // Restore CG state.
    //
    CGContextRestoreGState(context);
}


@end
