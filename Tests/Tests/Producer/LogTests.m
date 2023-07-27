//
// Copyright 2023 aliyun-sls Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "BaseTestCase.h"
#import "AliyunLogProducer/AliyunLogProducer.h"
#import "Log+Test.h"

QuickSpecBegin(LogTests)

__block Log *log = nil;
beforeEach(^{
    log = [Log log];
});

afterEach(^{
    [log clear];
});

describe(@"putContent:value", ^{
    it(@"put stringValue", ^{
        [log putContent:@"stringValue" value:@"stringValue"];
        expect(log.getContent[@"stringValue"]).to(equal(@"stringValue"));
    });
    
    it(@"put stringValue with nil", ^{
        [log putContent:@"stringValue" value:nil];
        expect(log.getContent[@"stringValue"]).to(beNil());
    });
    
    it(@"put stringValue with empty", ^{
        [log putContent:@"stringValue" value:@""];
        expect(log.getContent[@"stringValue"]).to(equal(@""));
    });
    
    it(@"put stringValue with NSNull", ^{
        [log putContent:@"stringValue" value:[NSNull null]];
        expect(log.getContent[@"stringValue"]).to(beNil());
    });
});

describe(@"PutContent:value", ^{
    it(@"put string value", ^{
        [log PutContent:@"stringValue" value:@"testValue"];
        expect(log.getContent[@"stringValue"]).to(equal(@"testValue"));
    });
});

describe(@"putContent:intValue", ^{
    it(@"put intValue", ^{
        [log putContent:@"int" intValue:121];
        expect([log.getContent[@"int"] intValue]).to(equal(121));
    });
});

describe(@"putContent:data", ^{
    it(@"put NSDictionary", ^{
        NSDictionary *dict = @{
            @"key": @"value"
        };
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        [log putContent:data];
        expect(log.getContent[@"key"]).to(equal(dict[@"key"]));
    });
    
    it(@"put NSArray", ^{
        NSArray *array = @[
            @"array"
        ];
        NSData *data = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
        [log putContent:data];
        expect(log.getContent[@"data"]).to(equal([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]));
    });
    
    it(@"put NSString", ^{
        NSData *data = [@"value" dataUsingEncoding:NSUTF8StringEncoding];
        [log putContent:data];
        expect(log.getContent[@"data"]).to(equal(@"value"));
    });
    
    it(@"put NSNull", ^{
        NSData *data = [NSNull null];
        [log putContent:data];
        expect(log.getContent[@"data"]).to(equal(@"null"));
    });
});

describe(@"putContent:dataValue", ^{
    it(@"put dataValue", ^{
        NSData *data = [@"dataValue" dataUsingEncoding:NSUTF8StringEncoding];
        [log putContent:@"key" dataValue:data];
        expect(log.getContent[@"key"]).to(equal(@"dataValue"));
    });
    
});

describe(@"putContent:dictValue", ^{
    it(@"dict value is a valid json", ^{
        NSDictionary *dict = @{
            @"key1": @"value1",
            @"key2": @2
        };
        
        BOOL result = [log putContent:@"key" dictValue:dict];
        expect(result).to(beTrue());
        
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:kNilOptions
                                                         error:&error
        ];
        NSString *expectString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding
        ];
        expect(log.getContent[@"key"]).to(equal(expectString));
    });
    
    it(@"dict value is not a valid json", ^{
        NSDictionary *dict = @{
            @"key1": @"value1",
            @"key2": [[NSObject alloc] init]
        };
        
        BOOL result = [log putContent:@"key" dictValue:dict];
        expect(result).to(beFalse());
        expect(log.getContent[@"key"]).to(beNil());
    });
});

describe(@"putContent:arrayValue", ^{
    it(@"array value is a valid json", ^{
        NSArray *arry = @[
            @"key1", @"key2"
        ];
        
        BOOL result = [log putContent:@"key" arrayValue:arry];
        expect(result).to(beTrue());
        
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:arry
                                                       options:kNilOptions
                                                         error:&error
        ];
        NSString *expectString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding
        ];
        expect(log.getContent[@"key"]).to(equal(expectString));
    });
    
    it(@"array value is not a valid json", ^{
        NSArray *arry = @[
            @"key1", [[NSObject alloc] init]
        ];
        
        BOOL result = [log putContent:@"key" arrayValue:arry];
        expect(result).to(beFalse());
        expect(log.getContent[@"key"]).to(beNil());
    });
});

describe(@"putContent:longValue", ^{
    describe(@"its put long value", ^{
        it(@"has this long value", ^{
            [log putContent:@"int" longValue:121];
            expect([log.getContent[@"int"] intValue]).to(equal(121));
        });
    });
});

describe(@"putContent:longlongValue", ^{
    describe(@"its put longlong value", ^{
        it(@"has this longlong value", ^{
            [log putContent:@"int" longlongValue:121];
            expect([log.getContent[@"int"] intValue]).to(equal(121));
        });
    });
});

describe(@"putContent:floatValue", ^{
    describe(@"its put float value", ^{
        it(@"has this float value", ^{
            [log putContent:@"float" floatValue:121.0f];
            expect([log.getContent[@"float"] floatValue]).to(equal(121.0f));
        });
    });
});

describe(@"putContent:doubleValue", ^{
    describe(@"its put double value", ^{
        it(@"has this double value", ^{
            [log putContent:@"double" doubleValue:121.0f];
            expect([log.getContent[@"double"] floatValue]).to(equal(121.0f));
        });
    });
});

describe(@"putContent:boolValue", ^{
    describe(@"its put bool value", ^{
        it(@"has this bool value", ^{
            [log putContent:@"bool" boolValue:YES];
            expect([log.getContent[@"bool"] boolValue]).to(beTrue());
        });
    });
});

describe(@"SetTime", ^{
    it(@"has this time", ^{
        unsigned int logTime = 11111;
        [log SetTime:logTime];
        expect(log.getTime).to(equal(logTime));
    });
});

QuickSpecEnd
