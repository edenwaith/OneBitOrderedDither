//
//  OneBitDitheredOrderPlugin.h
//  OneBitDitheredOrder
//
//  Created by Chad Armstrong on 9/03/2023.
//  Copyright © 2023 Edenwaith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
// Added to fix the error "Definition of 'CIFilter' must be imported from module 'CoreImage.CIFilter' before it is required" in Xcode 14
#import <CoreImage/CIFilter.h>

#import "ACPlugin.h"


NS_ASSUME_NONNULL_BEGIN

@interface OneBitDitheredOrderPlugin : NSObject <ACPlugin>

@end

NS_ASSUME_NONNULL_END
