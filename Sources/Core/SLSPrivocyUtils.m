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
	

#import "SLSPrivocyUtils.h"

@interface SLSPrivocyUtils ()
@property(atomic, assign) BOOL privocy;
@end

@implementation SLSPrivocyUtils
+ (instancetype) sharedInstance {
    static SLSPrivocyUtils * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SLSPrivocyUtils alloc] init];
        ins.privocy = NO;
    });
    return ins;
}

- (void)internal_setEnablePrivocy:(BOOL)enablePrivocy {
    self.privocy = enablePrivocy;
}

- (BOOL) internal_isEnablePrivocy {
    return self.privocy;
}

+ (void) setEnablePrivocy: (BOOL) enablePrivocy {
    [[self sharedInstance] internal_setEnablePrivocy:enablePrivocy];
}

+ (BOOL) isEnablePrivocy {
    return [[self sharedInstance] internal_isEnablePrivocy];
}
@end
