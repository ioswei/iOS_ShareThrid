#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TYSnapshotScroll.h"
#import "UIImage+TYSnapshot.h"
#import "UIScrollView+TYSnapshot.h"
#import "UIViewController+TYSnapshot.h"
#import "WKWebView+TYSnapshot.h"

FOUNDATION_EXPORT double TYSnapshotScrollVersionNumber;
FOUNDATION_EXPORT const unsigned char TYSnapshotScrollVersionString[];

