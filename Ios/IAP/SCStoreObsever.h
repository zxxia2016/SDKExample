//
//  SCStoreObsever.h
//  hello_world-mobile
//
//  Created by apple  on 23.03.21.
//
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>

@interface SCStoreObsever : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    int buyType;
    int buyServerId;
    int buyAccountId;
    BOOL buyStatus;
    int buyCount;
    int buyMoney;
    NSString* ProductID;
}

@property (nonatomic, strong) UIView *loadingView;

- (void) RequestProductData;
- (bool) CanMakePay;
- (void) buy:(int)idAccount  money:(int)money  count:(int)count;
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) PurchasedTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
- (void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent:(NSString *)product;
- (void) recordTransaction:(NSString *)product;
- (void) updateBuyStatus:(NSString*)status;
- (BOOL) checkPay;
- (void) SavePayUrl:(NSString*) url;


@end
