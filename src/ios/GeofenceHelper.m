//
//  GeofenceHelper.m
//  OutSystems
//
//  Created by Vitor Oliveira on 20/04/16.
//
//

#import "GeofenceHelper.h"
#import "OutSystems-Swift.h"

@implementation GeofenceHelper

+(BOOL) validateTimeIntervalWithDictionary: (NSDictionary *) parsedData {
    Boolean showNotification = NO;
    //Compare with dates of event to validate if we should create the Local Notification
    NSString * timeDateStart = [[parsedData valueForKey:@"notification"] valueForKey:@"dateStart"];
    NSString * timeDateEnd = [[parsedData valueForKey:@"notification"] valueForKey:@"dateEnd"];
    BOOL happensOnce = [[[parsedData valueForKey:@"notification"] valueForKey:@"happensOnce"] boolValue];
    BOOL notificationShowed = [[[parsedData valueForKey:@"notification"] valueForKey:@"notificationShowed"] boolValue];
    
    if(!timeDateStart && !timeDateEnd) {
        showNotification = YES;
        NSLog(@"Time Date not defined...");
    } else {
        NSLog(@"Time Date defined...");
        
        if(notificationShowed && happensOnce) {
            showNotification = NO;
            return showNotification;
        }
        
        //Get Date Now
        NSDate * dateNow = [NSDate date];
        // Convert Date String to NSDate
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        //[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *_timeDateStart = [formatter dateFromString:timeDateStart];
        NSDate *_timeDateEnd = [formatter dateFromString:timeDateEnd];
        
        if (timeDateStart && _timeDateStart) {
            NSComparisonResult result = [dateNow compare:_timeDateStart];
            
            if(result == NSOrderedDescending || result == NSOrderedSame)
                showNotification = YES;
            else
                showNotification = NO;
        }
        if (timeDateEnd && _timeDateEnd) {
            NSComparisonResult result = [dateNow compare:_timeDateEnd];
            if(!_timeDateStart || [_timeDateStart compare:_timeDateEnd] == NSOrderedAscending){
                if(result == NSOrderedAscending || result == NSOrderedSame)
                    showNotification = YES;
                else
                    showNotification = NO;
            }
        }
        
        if(!notificationShowed && happensOnce) {
            [[parsedData valueForKey:@"notification"] setValue:[NSNumber numberWithBool:YES] forKey:@"notificationShowed"];
            
            // Update Geofence
            NSError * err;
            NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:parsedData options:0 error:&err];
            NSString * geofenceStr = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
            
            WrapperStore *wrapper = [[WrapperStore alloc] init];
            [wrapper updateDB:geofenceStr];
        }
    }
    
    return showNotification;
}

+(BOOL) validateTimeIntervalWithString: (NSString*) geofenceStr {
    NSError *jsonError;
    NSData *objectData = [geofenceStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:objectData
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&jsonError];
    return [self validateTimeIntervalWithDictionary:parsedData];

}


@end