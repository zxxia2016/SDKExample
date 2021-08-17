# 谷歌登录
谷歌登录相关教程

1. 参考教程链接：https://blog.csdn.net/qq_43540406/article/details/114589168
2. 主要流程：
   1. Google API控制台，创建OAuth2.0 ClientID
      1. 在凭据中创建Type为Android的ClientID，然后将秘钥的sha1和包名填入
         1. 注意点：包名和sha1值要匹配；调试的时候用的是debug的秘钥，可能会提示获取失败
      2. 在凭据中创建Type为Web application的ClientID，然后获取ClientID，添加到strings.xml中
   2. android工程中添加如下代码
      1. build.gradle中添加如下代码：```implementation 'com.google.android.gms:play-services-auth:19.0.0'```
      2. 主要代码段: 
         1. ```GoogleSignIn.getClient```
         2. ```signIn```
         3. ```onActivityResult```