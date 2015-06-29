//
//  ISWebCache.m
//  ZhiHuInterviewProject
//
//  Created by ice on 15/6/26.
//  Copyright © 2015年 icenoie. All rights reserved.
//

#import "ISWebCache.h"

#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ISGlobalSettings.h"

#define IS_DATA_NETWORK_TIMEOUT 5
#define IS_CACHE_TIMEOUT_INTERVAL 86400
#define IS_CACHE_FILENAME_LENGTH 14

@interface ISWebCache ()

@property (strong, nonatomic) ISGlobalSettings *gs;
@property (strong, nonatomic) NSString *cacheDir;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (nonatomic) dispatch_queue_t loadingQueue;

@end

@implementation ISWebCache


- (instancetype)init
{
    self = [super init];
    if (self) {
        _gs = [ISGlobalSettings sharedSettings];
        _loadingQueue = dispatch_queue_create("listLoading", DISPATCH_QUEUE_SERIAL);
        _context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        _cacheDir = _gs.cacheDir;
        
        NSString *urlStr = [[_gs applicationDocumentsDirectory] URLByAppendingPathComponent:_cacheDir].absoluteString;
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:urlStr error:nil];
        if (array == nil) {
            [[NSFileManager defaultManager] createDirectoryAtPath:urlStr withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [[NSFileManager defaultManager] contentsOfDirectoryAtPath:urlStr error:nil];
    }
    return self;
}

+ (ISWebCache *)sharedWebCache
{
    static ISWebCache *wc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (wc == nil) {
            wc = [[self alloc] init];
        }
    });
    return wc;
}


- (void)pullFromServerWithURL:(NSURL *)url andCompletionHandler:(void (^)(NSData *data, BOOL isCached, BOOL isSuccessful))handler
{
    __block NSData *cacheData;
    NSString *itemIDStr = [[url.absoluteString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    itemIDStr = [itemIDStr substringWithRange:NSMakeRange(itemIDStr.length - IS_CACHE_FILENAME_LENGTH, IS_CACHE_FILENAME_LENGTH)];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ISWebCacheDB" inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSString *escapedItemIDStr = [NSRegularExpression escapedPatternForString:itemIDStr];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID MATCHES[c] %@", escapedItemIDStr];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeout"
//                                                                   ascending:NO];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects != nil && [fetchedObjects count] > 0) {
        NSManagedObject *context = [fetchedObjects firstObject];
        NSString *dataPathStr = [context valueForKey:@"dataPathStr"];
        NSDate *timeoutDate = [context valueForKey:@"createDate"];
        if (!dataPathStr) {
            NSLog(@"%@ Unexpected error when reading path of cache. Trying fetch from remote...", [self class]);
        } else {
            
            //Check for cache timeout
            if ([[NSDate date] timeIntervalSinceDate:timeoutDate] < IS_CACHE_TIMEOUT_INTERVAL) {
                NSURL *ad = [_gs applicationDocumentsDirectory];
                dataPathStr = [ad URLByAppendingPathComponent:dataPathStr].absoluteString;
                dataPathStr = [dataPathStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                cacheData = [[NSData alloc] initWithContentsOfFile:dataPathStr];
                
                if (!cacheData) {
                    NSLog(@"%@ Unexpected error when reading path of cache. Trying fetch from remote...", [self class]);
                }
            }
        }
    }
    if (!cacheData) {
//        NSLog(@"%@ Cache not hit, fetching from remote", [self class]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), _loadingQueue, ^{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.timeoutInterval = IS_DATA_NETWORK_TIMEOUT;
            cacheData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            if (!cacheData) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ISNoInternetConnectionAlert" object:nil];
                handler([cacheData copy], NO, NO);
                
            } else {
                
                //Cache content
                NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"ISWebCacheDB" inManagedObjectContext:_context];
                [object setValue:itemIDStr forKey:@"itemID"];
                [object setValue:[NSDate date] forKey:@"createDate"];
                
                NSString *dataPathStr = [NSString stringWithFormat:@"/%@", itemIDStr];
                
                dataPathStr = [_cacheDir stringByAppendingString:dataPathStr];
                
                
                NSString *realDataPathStr = [[_gs applicationDocumentsDirectory].absoluteString stringByAppendingString:dataPathStr];
                realDataPathStr = [realDataPathStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                
                if (![[NSFileManager defaultManager] createFileAtPath:realDataPathStr contents:cacheData attributes:nil]) {
                    
                    NSLog(@"%@: Unexpected error when saving cache", [self class]);
                }
                [object setValue:dataPathStr forKey:@"dataPathStr"];
                [_context save:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler([cacheData copy], NO, YES);
                });
            }

        });
        
    } else {
        
        //Load from cache
        handler([cacheData copy], YES, YES);
    }
    
//    NSString *str = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:itemIDStr options:NSDataBase64DecodingIgnoreUnknownCharacters] encoding:NSUTF8StringEncoding];
    
    
}

@end
