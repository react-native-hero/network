#import "RNTNetwork.h"
#import <React/RCTConvert.h>
#import <AFNetworking/AFNetworking.h>
#include <CommonCrypto/CommonDigest.h>

NSString *ERROR_CODE_DOWNLOAD_FAILURE = @"1";
NSString *ERROR_CODE_UPLOAD_FAILURE = @"2";

NSDictionary* getFileInfo(NSURL *url) {
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSInteger size = [data length];

    NSString *path = url.absoluteString;
    NSString *prefix = @"file://";
    if ([path hasPrefix:prefix]) {
        path = [path substringFromIndex:[prefix length]];
    }

    return @{
       @"path": path,
       @"name": path.lastPathComponent,
       @"size": @(size),
    };
    
}

NSURL* getFileURL(NSString *path) {
    
    // fileURLWithPath 要求格式为 file:// 开头
    NSString *prefix = @"file:/";
    if (![path hasPrefix:prefix]) {
        path = [prefix stringByAppendingString:path];
    }
    
    return [NSURL fileURLWithPath:path];
    
}

@implementation RNTNetwork

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_queue_create("com.github.reactnativehero.network", DISPATCH_QUEUE_SERIAL);
}

- (NSArray<NSString *> *)supportedEvents {
  return @[
      @"download_progress",
      @"upload_progress",
  ];
}

- (NSDictionary *)constantsToExport {
    return @{
        @"ERROR_CODE_DOWNLOAD_FAILURE": ERROR_CODE_DOWNLOAD_FAILURE,
        @"ERROR_CODE_UPLOAD_FAILURE": ERROR_CODE_UPLOAD_FAILURE,
    };
}

RCT_EXPORT_MODULE(RNTNetwork);

RCT_EXPORT_METHOD(download:(NSDictionary*)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {

    int index = [RCTConvert int:options[@"index"]];
    
    NSString *url = [RCTConvert NSString:options[@"url"]];
    NSString *path = [RCTConvert NSString:options[@"path"]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDownloadTask *downloadTask = [manager
            downloadTaskWithRequest:request
            progress:^(NSProgress *progress) {
                if (index > 0) {
                    [self sendEventWithName:@"download_progress" body:@{
                        @"index": @(index),
                        @"progress": @(progress.fractionCompleted),
                    }];
                }
            }
            destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [NSURL fileURLWithPath:path];
            }
            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error == nil) {
                    resolve(getFileInfo(filePath));
                }
                else {
                    reject(ERROR_CODE_DOWNLOAD_FAILURE, error.localizedDescription, error);
                }
            }
    ];
    
    [downloadTask resume];

}

RCT_EXPORT_METHOD(upload:(NSDictionary*)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {

    int index = [RCTConvert int:options[@"index"]];
    
    NSString *url = [RCTConvert NSString:options[@"url"]];

    NSDictionary *file = [RCTConvert NSDictionary:options[@"file"]];
    NSDictionary *data = [RCTConvert NSDictionary:options[@"data"]];
    
    NSString *path = file[@"path"];
    NSString *name = file[@"name"];
    NSString *fileName = file[@"fileName"];
    NSString *mimeType = file[@"mimeType"];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
            // 上传文件
            [formData appendPartWithFileURL:getFileURL(path) name:name fileName:fileName mimeType:mimeType error:nil];
        
            // 附带其他参数
            if (data != nil) {
                for (NSString *key in data) {
                    [formData appendPartWithFormData:data[key] name:key];
                }
            }
            
        } error:nil];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionUploadTask *uploadTask = [manager
            uploadTaskWithStreamedRequest:request
            progress:^(NSProgress *progress) {
                if (index > 0) {
                    [self sendEventWithName:@"upload_progress" body:@{
                        @"index": @(index),
                        @"progress": @(progress.fractionCompleted),
                    }];
                }
            }
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error == nil) {
                    NSLog(@"upload response %@;\n", response);
                    NSLog(@"upload responseObject %@;\n", responseObject);
                }
                else {
                    reject(ERROR_CODE_UPLOAD_FAILURE, error.localizedDescription, error);
                }
            }
    ];

    [uploadTask resume];

}

@end
