#import "FlutterAesPlugin.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation FlutterAesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_aes_zeropadding"
            binaryMessenger:[registrar messenger]];
  FlutterAesPlugin* instance = [[FlutterAesPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"aes" isEqualToString:call.method]) {
      result(aesEncryptString(call.arguments[@"pw"], call.arguments[@"key"], call.arguments[@"iv"]));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

NSString * aesEncryptString(NSString *content, NSString *key, NSString *iv) {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encrptedData = aesEncryptData(contentData, keyData, ivData);
    return [encrptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}
NSData * aesEncryptData(NSData *contentData, NSData *keyData, NSData *ivData) {
    return AES128CBCNoPaddingEncrypt(contentData, keyData, ivData, kCCEncrypt);
}

//NSData * cipherOperation(NSData *contentData, NSData *keyData, NSData *ivData, CCOperation operation) {
//    NSUInteger dataLength = contentData.length;
//    void const *initVectorBytes = ivData.bytes;
//    void const *contentBytes = contentData.bytes;
//    void const *keyBytes = keyData.bytes;
//
//    size_t operationSize = dataLength + kCCBlockSizeAES128;
//    void *operationBytes = malloc(operationSize);
//    if (operationBytes == NULL) {
//        return nil;
//    }
//    size_t actualOutSize = 0;
//
//    CCCryptorStatus cryptStatus = CCCrypt(operation,
//                                          kCCAlgorithmAES,
////                                          kCCOptionPKCS7Padding, // 与其他平台的PKCS5Padding相等
//                                           0x0000,
//                                          keyBytes,
//                                          kCCKeySizeAES128,  // 秘钥长度选择AES128
//                                          initVectorBytes,
//                                          contentBytes,
//                                          dataLength,
//                                          operationBytes,
//                                          operationSize,
//                                          &actualOutSize);
//
//    if (cryptStatus == kCCSuccess) {
//        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
//    }
//
//    free(operationBytes);
//    operationBytes = NULL;
//    return nil;
//}

//nopadding7

NSData * AES128CBCNoPaddingEncrypt(NSData *contentData, NSData *keyData, NSData *ivData, CCOperation operation) {
    if (!contentData || !keyData || !ivData) {
        return nil;
    }
    void const *keyPtr = keyData.bytes;
    void const *ivPtr = ivData.bytes;
    
    NSUInteger dataLength = [contentData length];
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    NSInteger newSize = 0;
    
    if(diff > 0) {
        newSize = dataLength + diff;
    }
    
    //不足16字节的倍数，则使用0x00自动补齐长度
    char dataPtr[newSize];
    memcpy(dataPtr, [contentData bytes], [contentData length]);
    for(int i = 0; i < diff; i++) {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          0x0000,//NoPadding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    }
    free(buffer);
    return nil;
}

@end
