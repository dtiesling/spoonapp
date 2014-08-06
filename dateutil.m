//
//  dateutil.m
//  Resty
//
//  Created by Daniel Tiesling on 6/25/14.
//  Copyright (c) 2014 Daniel Tiesling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dateutil.h"

int dayOffset = 0;
NSDate* today () {
    NSDate *rightNow = [[NSDate alloc] init];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents * calComponents = [cal components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:rightNow];
    
    // Current day of week, with hours, minutes and seconds zeroed-out
//    int today = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:rightNow] weekday];
    
    [calComponents setDay:([calComponents day] + dayOffset)];
     
    NSDate *beginningOfDay = [cal dateFromComponents:calComponents];
    return beginningOfDay;
}
    
