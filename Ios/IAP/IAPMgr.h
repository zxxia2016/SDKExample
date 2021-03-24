//
//  IAPMgr.h
//  hello_world-mobile
//
//  Created by apple on 19.03.23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IAPMgr : NSObject
+ (instancetype) getInstance;

-(void) initObserver;
-(void) onPay:(int)account money:(int)money  count:(int)count;
@end

NS_ASSUME_NONNULL_END
