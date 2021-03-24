# 苹果内购 说明
## 1.接入参考官方地址：
- https://developer.apple.com/cn/in-app-purchase/
## 2.接入步骤：
1. 将依赖库**StoreKit.framework**添加到Xcode工程，如图：![image](https://raw.githubusercontent.com/zxxia2016/SDKExample/main/Ios/IAP/Image/1.jpg)
2. 编码部分:
   1. RootViewController.mm文件中初始化
   ```
    #import "IAPMgr.h"

    [[IAPMgr getInstance] initObserver];
   ```
3. IAPMgr.m文件
   1. 初始化代码
   ```
   -(void) initObserver
   ```
   1. 支付代码
   ```
   - (void) onPay:(int)account money:(int)money  count:(int)count
   ```
4. SCStoreObsever.h文件
   1.  继承SKProductsRequestDelegate, SKPaymentTransactionObserver
   ```
   @interface SCStoreObsever : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>
   ```
5. SCStoreObsever.mm文件
   1. 支付代码
   ```
   - (void) buy:(int)idAccount  money:(int)money count:(int)count
   ``` 
   2. 查询productid
   ```
   -(void)RequestProductData
   ```
   3. 查询productid结果,如果查询到商品信息，就发起支付
   ```
   - (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
   ```
   4. 支付结果,如果支付成功，就去服务器验证
   ```
   - (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
   ```
5. 测试
   1. 替换SCStoreObsever.mm文件中以下几个地方
    ```
    ProductID = [NSString stringWithFormat:@"com.aa.bb.cny%d", money];

    NSString* strUrl = @"http://www.baidu.com/pay/iosPayment";//server api
    ```
   2. 注意几点：
      1. 包名一致
      2. 开发者账号要统一
      3. 沙盒测试账号

    