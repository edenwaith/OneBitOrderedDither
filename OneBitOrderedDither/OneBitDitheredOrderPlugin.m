//
//  OneBitDitheredOrderPlugin.m
//  OneBitDitheredOrder
//
//  Created by Chad Armstrong on 9/03/2023.
//  Copyright © 2023 Edenwaith. All rights reserved.
//
//	Copy this plug-in to the ~/Library/Application Support/Acorn/Plug-Ins folder

#import "OneBitDitheredOrderPlugin.h"

@implementation OneBitDitheredOrderPlugin

// This matrix comes from https://www.codeproject.com/Articles/5259216/Dither-Ordered-and-Floyd-Steinberg-Monochrome-Colo
const	int	BAYER_PATTERN_16X16[16][16]	=	{	//	16x16 Bayer Dithering Matrix.  Color levels: 256
												{	  0, 191,  48, 239,  12, 203,  60, 251,   3, 194,  51, 242,  15, 206,  63, 254	},
												{	127,  64, 175, 112, 139,  76, 187, 124, 130,  67, 178, 115, 142,  79, 190, 127	},
												{	 32, 223,  16, 207,  44, 235,  28, 219,  35, 226,  19, 210,  47, 238,  31, 222	},
												{	159,  96, 143,  80, 171, 108, 155,  92, 162,  99, 146,  83, 174, 111, 158,  95	},
												{	  8, 199,  56, 247,   4, 195,  52, 243,  11, 202,  59, 250,   7, 198,  55, 246	},
												{	135,  72, 183, 120, 131,  68, 179, 116, 138,  75, 186, 123, 134,  71, 182, 119	},
												{	 40, 231,  24, 215,  36, 227,  20, 211,  43, 234,  27, 218,  39, 230,  23, 214	},
												{	167, 104, 151,  88, 163, 100, 147,  84, 170, 107, 154,  91, 166, 103, 150,  87	},
												{	  2, 193,  50, 241,  14, 205,  62, 253,   1, 192,  49, 240,  13, 204,  61, 252	},
												{	129,  66, 177, 114, 141,  78, 189, 126, 128,  65, 176, 113, 140,  77, 188, 125	},
												{	 34, 225,  18, 209,  46, 237,  30, 221,  33, 224,  17, 208,  45, 236,  29, 220	},
												{	161,  98, 145,  82, 173, 110, 157,  94, 160,  97, 144,  81, 172, 109, 156,  93	},
												{	 10, 201,  58, 249,   6, 197,  54, 245,   9, 200,  57, 248,   5, 196,  53, 244	},
												{	137,  74, 185, 122, 133,  70, 181, 118, 136,  73, 184, 121, 132,  69, 180, 117	},
												{	 42, 233,  26, 217,  38, 229,  22, 213,  41, 232,  25, 216,  37, 228,  21, 212	},
												{	169, 106, 153,  90, 165, 102, 149,  86, 168, 105, 152,  89, 164, 101, 148,  85	}
											};

+ (id) plugin {
    return [[self alloc] init];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager addFilterMenuTitle:@"1-Bit Ordered Dither"
                   withSuperMenuTitle:@"Color Adjustment"
                               target:self
                               action:@selector(convert:userObject:)
                        keyEquivalent:@""
            keyEquivalentModifierMask:0
                           userObject:nil];
}

- (void)didRegister {
    
}

- (NSNumber*) worksOnShapeLayers:(id)userObject {
	return [NSNumber numberWithBool:NO];
}

- (NSNumber*) validateForLayer:(id<ACLayer>)layer {
	
	if ([layer layerType] == ACBitmapLayer) {
		return [NSNumber numberWithBool:YES];
	}
	
	return [NSNumber numberWithBool:NO];
}

/// Use a 16x16 Bayer ordered dither matrix to create a 1-bit black and white image
/// @param image The original image to dither
/// @param userObject The user object
- (CIImage *) convert:(CIImage *)image userObject:(id)userObject {
	
	NSBitmapImageRep *initialBitmap = [[NSBitmapImageRep alloc] initWithCIImage: image];
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCIImage: image];
	NSSize originalImageSize = [initialBitmap size];
	int imageHeight = (int)originalImageSize.height;
	int imageWidth = (int)originalImageSize.width;
	int col = 0;
	int row = 0;
	int ditherLevel = 16;
	int modVal = ditherLevel - 1;

	for (int y = 0; y < imageHeight; y++)
	{
		// Use a bitwise AND operator instead of using the mod operator for a potential speed improvement
		row  = y & modVal; // y & 15 == y % 16
		
		for (int x = 0; x < imageWidth; x++)
		{
			col = x & modVal; // x & 15 == x % 16
			
			NSColor *originalPixelColor = [bitmap colorAtX:x y:y];
			CGFloat red   = [originalPixelColor redComponent];
			CGFloat green = [originalPixelColor greenComponent];
			CGFloat blue  = [originalPixelColor blueComponent];
			
			// Divide by 255.0 to normalize the value
			CGFloat bayerDitherValue =  BAYER_PATTERN_16X16[col][row] / 255.0;
			CGFloat avgPixelColor = (red + green + blue)/3.0; // grayscale value
			CGFloat newColor = 0.0;
			
			// For some of the matrices (8x8 and 16x16), if the avgPixelColor is full black or white might be
			// incorrectly calculated.
			if (avgPixelColor == 0.0 || avgPixelColor == 1.0) {
				newColor = avgPixelColor;
			} else {
				newColor = avgPixelColor < bayerDitherValue ? 0 : 1.0;
			}
			
			NSColor *newPixelColor = [NSColor colorWithCalibratedRed:newColor green:newColor blue:newColor alpha:1.0];
			[bitmap setColor:newPixelColor atX:x y:y];
		}
	}
	
	// Return the modified CIImage
	CIImage *outputImage = [[CIImage alloc] initWithBitmapImageRep: bitmap];
		
	return outputImage;
}

@end
