//
//  SLSSystemCapabilities.h
//  Pods
//
//  Created by gordon on 2022/3/9.
//

#ifndef SLSSystemCapabilities_h
#define SLSSystemCapabilities_h

#ifdef __APPLE__
#include <TargetConditionals.h>
#define SLS_HOST_APPLE 1
#endif

#define SLS_HOST_IOS (SLS_HOST_APPLE && TARGET_OS_IOS)
#define SLS_HOST_TV (SLS_HOST_APPLE && TARGET_OS_TV)
#define SLS_HOST_WATCH (SLS_HOST_APPLE && TARGET_OS_WATCH)
#define SLS_HOST_MAC (SLS_HOST_APPLE && TARGET_OS_MAC && !(TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH))

#if SLS_HOST_IOS || SLS_HOST_TV || SLS_HOST_WATCH
#define SLS_HAS_UIKIT 1
#else
#define SLS_HAS_UIKIT 0
#endif

#endif /* SLSSystemCapabilities_h */
