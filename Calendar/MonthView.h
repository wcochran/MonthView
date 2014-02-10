//
//  MonthView.h
//  Calendar
//
//  Created by Wayne Cochran on 2/9/14.
//  Copyright (c) 2014 Wayne Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthView : UIView

@property (strong, nonatomic) NSDate *date;

@property (copy, nonatomic) NSString *monthYearString;
@property (assign, nonatomic) NSInteger startDayOfWeek;
@property (assign, nonatomic) NSInteger numberOfDays;
@property (assign, nonatomic) NSInteger numberOfDaysInPreviousMonth;

@end
