//
//  SCStoreObsever.m
//  hello_world-mobile
//
//  Created by apple  on 23.03.21.
//
//
#import "SCStoreObsever.h"

@implementation SCStoreObsever

-(void)updateBuyStatus:(NSString*)status{
    if([status isEqual:@"OFF"])
    {
        buyStatus = FALSE;
        [self startLoading: @"购买正在进行中\n请耐心等待噢...."];
        //GetDataMgr()->setPauseHeartCheck(true);
    }
    else
    {
        buyStatus = TRUE;
        [self stopLoading];
        //GetDataMgr()->setPauseHeartCheck(false);
    }
}

- (void)startLoading:(NSString*)content
{
    if(self.loadingView)return;
    CGRect cgrect = [[UIScreen mainScreen] bounds];
    self.loadingView =  [[UIView alloc]init];
    self.loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.loadingView.frame = cgrect;
    //self.loadingView.alpha = 0.1f;
    //self.loadingView.layer.cornerRadius = 5.0f;
    self.loadingView.layer.masksToBounds = YES;
    UIView* view = [[UIView alloc]init];
    view.backgroundColor = [UIColor blackColor];
    view.frame = CGRectMake(1, 1, 1, 1);
    view.alpha = 0.85f;
    view.layer.cornerRadius = 5.0f;
    view.layer.masksToBounds = YES;
    
    [self.loadingView addSubview:view];
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.loadingView];
    
    NSString* message = content;//@"购买正在进行中\n请耐心等待噢....";
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message boundingRectWithSize:CGSizeMake(290, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil].size;
    label.frame = CGRectMake(10, 50, LabelSize.width, LabelSize.height);
    label.text = message;
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17];
    [view addSubview:label];
    
    UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [view  addSubview:activity];
    [activity startAnimating];
    
    activity.frame = CGRectMake(LabelSize.width/2-15, 5, 50, 50);
    view.frame = CGRectMake((cgrect.size.width - LabelSize.width - 20)/2, cgrect.size.height / 2 -LabelSize.height/2 - 30, LabelSize.width+20, LabelSize.height+60);
}

- (void)stopLoading
{
    if(self.loadingView){
        [UIView animateWithDuration:1.0 animations:^{
            self.loadingView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
        }];
    }
}

- (void) buy:(int)idAccount  money:(int)money count:(int)count
{
    if([self checkPay] == YES) return;
    //int countArr[4] = {6, 30, 128, 328};
    ProductID = [NSString stringWithFormat:@"com.aa.bb.cny%d", money];
    buyServerId = 0;
    buyCount = count;
    buyMoney = money;
    buyAccountId = idAccount;
    
    // NSLog(@"-----------serverId=%d-----idAccount=%d--------", serverId, idAccount);
    if ([SKPaymentQueue canMakePayments]) {
        [self RequestProductData];
    }
    else
    {
        [self alertWithTitle:NSLocalizedString(@"温馨提示",NULL) message:@"您没允许应用程序内购买"];
    }
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}

-(void)RequestProductData
{
    if(buyStatus==FALSE)
    {
        return ;
    }
    
    [self updateBuyStatus:@"OFF"];
    NSArray *product = [[NSArray alloc] initWithObjects:ProductID,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
    [product release];
}

//<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *myProduct = response.products;
    //#ifdef SC_IS_TEST_ITUNESSTORE
    NSLog(@"-----------收到产品反馈信息--------------");
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %lu", (unsigned long)[myProduct count]);
    //#endif
    NSUInteger nCount = [myProduct count];
    if(nCount<=0)
    {
        [self alertWithTitle:NSLocalizedString(@"温馨提示",NULL) message:@"无法获得产品信息！"];
        [self updateBuyStatus:@"ON"];
    }
    // populate UI
    SKPayment *payment = nil;
    for(SKProduct *product in myProduct){
        //#ifdef SC_IS_TEST_ITUNESSTORE
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        //#endif
        payment = [SKPayment paymentWithProduct:product];
    }
    if(payment != nil)
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    [request autorelease];
}

- (void)requestProUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.aa.bb"];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
}

-(void) requestDidFinish:(SKRequest *)request
{
    
    
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
    [transactions release];
}

//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    //SCActivityIndicator::getSingleton()->close();
    for (SKPaymentTransaction *transaction in transactions)
    {
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                [self completeTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed://交易失败
            {
                [self failedTransaction:transaction];
                
                [self alertWithTitle:@"" message:@"购买失败，请重新尝试购买"];
            }
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                [self restoreTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
            {
            }
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodingStr = [receipt base64EncodedStringWithOptions:0];
    if(!encodingStr) {
        NSLog(@"no receipt");
        return ;
    }
    [self updateBuyStatus:@"OFF"];
    //第一步，创建url
    NSString* strUrl = @"http://www.baidu.com/pay/iosPayment";//server api
    NSString* strUrl2 = [NSString stringWithFormat:@"%@?uid=%d&data=%@&gid=1", strUrl,buyAccountId, encodingStr];
    NSLog(@"strUrl==%@", strUrl);
    
    //Todo：超时
    NSURL *url = [NSURL URLWithString: strUrl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    //[request setHTTPMethod:@"GET"];
    NSString *str = [NSString stringWithFormat: @"uid=%d&data=%@&gid=1", buyAccountId, encodingStr];
    NSLog(@"%@", str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    //假装 充值成功...
    //GetDataMgr()->setUserMoneyToRefrush(GetDataMgr()->getUserInfo().money + 30);

    //第三步，连接服务器
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSLog(@"url:%@",str);
    bool isSuccess = false;
    //GetDataMgr()->setUserMoneyToRefrush(GetDataMgr()->getUserInfo().money + buyCount);
    if ( response != nil) {
        NSMutableDictionary *dict = NULL;
        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        if(dict != nil){
            NSInteger code = [[dict objectForKey:@"state"] integerValue];
            if(code==0){
                //return ;//@"";
                isSuccess = true;
            }
            [self SavePayUrl: @""];
        }else{
            [self SavePayUrl:strUrl2];
            //return ;//@"服务器返回错误，未获取到json对象";
        }
    }else{
        [self SavePayUrl:strUrl2];
        //return ;//@"服务器返回错误";
    }
    
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self updateBuyStatus:@"ON"];
}

- (BOOL) checkPay
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString* strUrl = [ user objectForKey:@"ios_user_pay_cache"];
    NSLog(@"%@", strUrl);
    if(strUrl != nil && strUrl.length>0){
        [self startLoading:@"购买恢复中..."];
        NSURL *url = [NSURL URLWithString: strUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        NSError *error;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        bool isSuccess = false;
        if ( response != nil) {
            NSMutableDictionary *dict = NULL;
            //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
            dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            if(dict != nil){
                NSInteger code = [[dict objectForKey:@"state"] integerValue];
                if(code==0){
                    isSuccess = true;
                }
                [self SavePayUrl:@""];
            }else{
                
            }
        }else{
            
        }
        [self stopLoading];
        return TRUE;
    }
    return FALSE;
}

- (void) SavePayUrl:(NSString*) url
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:url forKey:@"ios_user_pay_cache"];
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    
}

//处理下载内容
-(void)provideContent:(NSString *)product{
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    if (transaction == nil) {
        return;
    }
    NSLog(@"交易失败 %ld", (long)transaction.error.code);
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"购买失败");
    }
    else
    {
        NSLog(@"用户取消交易");
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    //CPlatformSDK::shareManager()->OnPayFinish(0, 1, "", "itunes");
    [self updateBuyStatus:@"NO"];
    
}

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
}

- (void)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:  UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"关闭",nil) style:UIAlertActionStyleDefault handler:nil]];
    
    //弹出提示框；
    // [[AppController shareRootView] presentViewController:alert animated:true completion:nil];
}

@end
