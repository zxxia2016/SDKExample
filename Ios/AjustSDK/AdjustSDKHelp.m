//
//  AdjustSDKHelp.m
//  
//
//  Created by apple on 11.03.21.
//

#import "AdjustSDKHelp.h"

@implementation AdjustSDKHelp


static AdjustSDKHelp* _instance = nil;
static int AdJustCount = 0;
static NSString* AdjustKey = @"";
static bool Debug = true;

#pragma mark -
#pragma mark Singleton

+(instancetype) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [AdjustSDKHelp getInstance] ;
}

+(id) copyWithZone:(struct _NSZone *)zone
{
    return [AdjustSDKHelp getInstance] ;
}

#pragma mark -
#pragma mark Game Logic

-(void) init: (id)observer
{
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSString* key = [plistDic valueForKey:@"adjust_key"];
    NSString* preAdjustKey = [plistDic valueForKey:@"adjust_preinstallKey"];
    NSString *yourAppToken = Debug ? @"" : key;
    NSString *environment = Debug ? ADJEnvironmentSandbox : ADJEnvironmentProduction;
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                                environment:environment];
    if (preAdjustKey.length > 0)
    {
        [adjustConfig setDefaultTracker:preAdjustKey];
    }
    
    [adjustConfig setDelegate:observer];
    
    [Adjust appDidLaunch:adjustConfig];
}

-(void)logEvent: (NSString *)eventType andData: (NSString *)data andType: (NSString *)currencyType
{
    if (eventType.length > 0) {
        ADJEvent *event = [ADJEvent eventWithEventToken: eventType];
        [event addPartnerParameter:@"key" value:@"value"];
        if (currencyType.length > 0) {
            double amount = [data doubleValue];
            [event setRevenue:amount currency: currencyType];
        }

        [Adjust trackEvent:event];
    }
    else {
        NSLog(@"ajdust log event error: %@, %@, %@", eventType, data, currencyType);
    }
        
}

- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    NSLog(@"Attribution callback called!");
    NSLog(@"Attribution: %@%@", attribution.clickLabel, attribution.trackerToken);
    if (AdJustCount == 0) {
        AdJustCount++;
        if (attribution.clickLabel.length > 0) {
            AdjustKey = attribution.clickLabel;
        }
        else {
            AdjustKey = attribution.trackerToken;
        }
    }
}
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    NSLog(@"Event success callback called!");
    NSLog(@"Event success data: %@", eventSuccessResponseData);
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    NSLog(@"Event failure callback called!");
    NSLog(@"Event failure data: %@", eventFailureResponseData);
}

@end
