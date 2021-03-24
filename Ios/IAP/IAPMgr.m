//
//  IAPMgr.m
//  hello_world-mobile
//
//  Created by apple on 19.03.21.
//

#import "IAPMgr.h"
#import "SCStoreObsever.h"


@implementation IAPMgr

static IAPMgr* _instance = nil;
static SCStoreObsever* s_storeObser = NULL;

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
    return [IAPMgr getInstance] ;
}

+(id) copyWithZone:(struct _NSZone *)zone
{
    return [IAPMgr getInstance] ;
}

#pragma mark -
#pragma mark SDK Logic

-(void) initObserver {
    if(s_storeObser==NULL)
    {
        s_storeObser = [[SCStoreObsever alloc] init];
        [s_storeObser updateBuyStatus:@"ON"];
        [[SKPaymentQueue defaultQueue]addTransactionObserver: s_storeObser];
    }
}

- (void) onPay:(int)account money:(int)money  count:(int)count
{
    [s_storeObser buy:account money:money  count:count];
}

- (void) restoreCompletedTransactions{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
@end

