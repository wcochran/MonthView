//
//  LottoViewController.m
//  Calendar
//
//  Created by Wayne Cochran on 2/9/14.
//  Copyright (c) 2014 Wayne Cochran. All rights reserved.
//

#import "LottoViewController.h"
#import "MonthView.h"

@interface LottoViewController ()

@end

@implementation LottoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.monthView.date = [NSDate date];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
