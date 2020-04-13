#import "RNTNetwork.h"
#import <React/RCTConvert.h>
#import <AFNetworking/AFNetworking.h>

@implementation RNTNetwork

static NSString *ERROR_CODE_DOWNLOAD_FAILURE = @"1";
static NSString *ERROR_CODE_UPLOAD_FAILURE = @"2";

static NSDictionary* getFileInfo(NSURL *url) {
    
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

static NSData* getFileData(NSString *path) {
    
    return [NSData dataWithContentsOfFile:path];

}

static NSString* dictionary2JsonString(NSDictionary *dict) {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

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
    NSDictionary *headers = [RCTConvert NSDictionary:options[@"headers"]];
    
    NSString *path = file[@"path"];
    NSString *name = file[@"name"];
    NSString *fileName = file[@"fileName"];
    NSString *mimeType = file[@"mimeType"];
    
    if (fileName == nil) {
        fileName = path.lastPathComponent;
    }
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    if (headers != nil) {
        for (NSString *key in headers) {
            [requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest *request = [requestSerializer
            multipartFormRequestWithMethod:@"POST"
            URLString:url
            parameters:data
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
                [formData appendPartWithFileData:getFileData(path) name:name fileName:fileName mimeType:mimeType];
            
            }
            error:nil
    ];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.responseSerializer = responseSerializer;
    
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
                    
                    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                    
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                        result[@"status_code"] = @(httpResponse.statusCode);
                    }
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *json = (NSDictionary*)responseObject;
                        // 安卓返回 map 比较麻烦，因此这里统一改成返回字符串
                        result[@"body"] = dictionary2JsonString(json);
                    }
                    
                    resolve(result);
                    
                }
                else {
                    reject(ERROR_CODE_UPLOAD_FAILURE, error.localizedDescription, error);
                }
            }
    ];

    [uploadTask resume];

}

@end
