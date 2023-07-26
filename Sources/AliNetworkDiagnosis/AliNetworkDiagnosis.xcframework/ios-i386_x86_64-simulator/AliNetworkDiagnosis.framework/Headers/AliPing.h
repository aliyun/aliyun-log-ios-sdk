//
//  AliPing.h
//  NetDiag
//
//

#import <AliNetworkDiagnosis/AliProtocols.h>
#import <AliNetworkDiagnosis/AliDetectConfig.h>
#import <Foundation/Foundation.h>

extern const int kAliInvalidPingResponse;

@interface AliPingResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSString* traceID;
@property (readonly) NSString* networkInterface;
@property (readonly) NSString* ip;
@property (readonly) NSUInteger size;
@property (readonly) NSTimeInterval maxRtt;
@property (readonly) NSTimeInterval minRtt;
@property (readonly) NSTimeInterval avgRtt;
@property (readonly) NSInteger loss;
@property (readonly) NSInteger count;
@property (readonly) NSTimeInterval totalTime;
@property (readonly) NSTimeInterval stddev;
@property (nonatomic,strong) NSString* errMsg;
@property (nonatomic,strong) NSString* content;

- (NSString*)description;

@end

typedef void (^AliPingCompleteHandler)(id context, NSString *traceID, AliPingResult *result);
// results: AliPingResult数组
typedef void (^AliPingCombineCompleteHandler)(id context, NSString *traceID, NSMutableArray<AliPingResult*> *results);

@interface AliPingConfig : AliDetectConfig

@property NSInteger timeout;
@property NSInteger size;
@property AliPingCompleteHandler complete;
@property AliPingCombineCompleteHandler combineComplete;
@property NSInteger interval;
@property BOOL parallel;

-(instancetype)init:(NSString*)host
            timeout:(NSInteger)timeout
          interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType
             prefer:(NSInteger)prefer
            context:(id)context
            traceID:(NSString*)traceID
               size:(NSInteger)size
              count:(NSInteger)count
           interval:(NSInteger)interval
           complete:(AliPingCompleteHandler)complete
    combineComplete:(AliPingCombineCompleteHandler)combineComplete;
@end

@interface AliPing : NSObject <AliStopDelegate>

+ (void)start:(NSString*)host
                 size:(NSUInteger)size
              traceID:(NSString*)traceID
              context:(id)context
               output:(id<AliOutputDelegate>)output
             complete:(AliPingCompleteHandler)complete;

+ (void)start:(NSString*)host
                 size:(NSUInteger)size
              traceID:(NSString*)traceID
              context:(id)context
               output:(id<AliOutputDelegate>)output
             complete:(AliPingCompleteHandler)complete
             interval:(NSInteger)interval
                count:(NSInteger)count;

+ (void)start:(NSString*)host
                 size:(NSUInteger)size
              traceID:(NSString*)traceID
              context:(id)context
             complete:(AliPingCompleteHandler)complete
             interval:(NSInteger)interval
                count:(NSInteger)count
        interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType;

+ (void)start:(NSString*)host
                 size:(NSUInteger)size
              traceID:(NSString*)traceID
              context:(id)context
             complete:(AliPingCombineCompleteHandler)complete
             interval:(NSInteger)interval
                count:(NSInteger)count;

+ (NSArray<AliPing*>*)startInstance:(NSString*)host
                 size:(NSUInteger)size
              traceID:(NSString*)traceID
              context:(id)context
             complete:(AliPingCompleteHandler)complete
             interval:(NSInteger)interval
                count:(NSInteger)count
        interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType;
+(void)execute:(AliPingConfig*)config;
-(void)stop;
-(void)setSwitchSize;
-(void)setExInfo:(NSDictionary*)info;
@end
