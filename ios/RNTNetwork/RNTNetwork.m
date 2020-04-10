#import "RNTNetwork.h"
#include <CommonCrypto/CommonDigest.h>

NSString *ERROR_CODE_FILE_NOT_FOUND = @"1";

@implementation RNTNetwork

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_queue_create("com.github.reactnativehero.network", DISPATCH_QUEUE_SERIAL);
}

- (NSDictionary *)constantsToExport {
    return @{
        @"DIRECTORY_CACHE": [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject],
        @"DIRECTORY_DOCUMENT": [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],
        @"ERROR_CODE_FILE_NOT_FOUND": ERROR_CODE_FILE_NOT_FOUND,
    };
}

RCT_EXPORT_MODULE(RNTNetwork);

RCT_EXPORT_METHOD(download:(NSString *)url resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {



}

@end
