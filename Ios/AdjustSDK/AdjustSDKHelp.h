//
//  Singleton.h
//  
//
//  Created by apple on 11.03.21.
//

#import <Foundation/Foundation.h>
#import <AdjustSdk/Adjust.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustSDKHelp : NSObject
+ (instancetype) getInstance;
- (void) init: (id)observer;
- (void)adjustAttributionChanged:(ADJAttribution *)attribution;
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData;
- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData;
@end

NS_ASSUME_NONNULL_END
