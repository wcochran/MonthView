//
//  MonthView.m
//  Calendar
//
//  Created by Wayne Cochran on 2/9/14.
//  Copyright (c) 2014 Wayne Cochran. All rights reserved.
//

#import "MonthView.h"

@interface MonthView ()

-(void)fetchMonthInfo;

@end

@implementation MonthView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
    self.startDayOfWeek = [dateComponents weekday];
    
    
    //
    // Get number of days in previous month.
    //
    const NSInteger year = [dateComponents year];
    const NSInteger month = [dateComponents month];
    const NSInteger previousMonthNum = (month == 1) ? 12 : (month - 1);
    const NSInteger previousMonthYear = (previousMonthNum == 12) ? year - 1 : year;
    dateComponents.month = previousMonthNum;
    dateComponents.year = previousMonthYear;
    NSDate *previousMonth = [calendar dateFromComponents:dateComponents];
    NSRange previousMonthDays = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:previousMonth];
    self.numberOfDaysInPreviousMonth = previousMonthDays.length;
    
    
    //
    // Get number of days in month containing 'self.date'.
    //
    NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit
                                  inUnit:NSMonthCalendarUnit
                                 forDate:self.date];
    self.numberOfDays = days.length;
    
    
    //
    // Get Header string for Month, Year containing 'self.date'.
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM YYYY";
    self.monthYearString = [dateFormatter stringFromDate:self.date];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.monthYearString == nil)
        [self fetchMonthInfo];
    
    NSLog(@"month start day of week = %d", self.startDayOfWeek);
    NSLog(@"number of days in month = %d", self.numberOfDays);
    NSLog(@"month ='%@'", self.monthYearString);
    NSLog(@"previous month days = %d", self.numberOfDaysInPreviousMonth);
    
    //UIFont *font = [UIFont boldSystemFontOfSize:30];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:30];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: [UIColor blackColor],
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    const CGSize headTextSize = [self.monthYearString sizeWithAttributes:attributes];
    const CGRect headRect = CGRectMake((700 - headTextSize.width)/2, (50 - headTextSize.height)/2,
                                       headTextSize.width, headTextSize.height);
    [self.monthYearString drawInRect:headRect withAttributes:attributes];
    
    NSArray *dowStrings = @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"];
    for (int c = 0; c < 7; c++) {
        NSString *dow = [dowStrings objectAtIndex:c];
        const CGSize dowSize = [dow sizeWithAttributes:attributes];
        const CGRect dowRect = CGRectMake(c*100 + (100 - dowSize.width)/2, 50 + (50 - dowSize.height),
                                          dowSize.width, dowSize.height);
        [dow drawInRect:dowRect withAttributes:attributes];
    }
    
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
    
    CGContextSetLineWidth(context, 4);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    int r = 1;
    int c = self.startDayOfWeek - 1;
    for (int d = 1; d <= self.numberOfDays; d++) {
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

}


@end
