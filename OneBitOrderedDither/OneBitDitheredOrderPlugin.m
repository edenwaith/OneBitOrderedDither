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

+ (id) plugin {
    return [[self alloc] init];
}

- (void) willRegister:(id<ACPluginManager>)pluginManager {
    
    [pluginManager addFilterMenuTitle:@"1-Bit Ordered Dither"
                   withSuperMenuTitle:@"Stylize"
                               target:self
                               action:@selector(convert:userObject:)
                        keyEquivalent:@""
            keyEquivalentModifierMask:0
                           userObject:nil];
}

- (void)didRegister {
    
}

// TODO: A bunch of template code, clean up and remove what is not needed.

// Reduce each color component to the closest EGA-style equivalent value.
// In hex, each component can only be 0x00, 0x55, 0xAA, or 0xFF (0, 85, 170, 255)
// 0x00 = 0 = 0
// 0x55 = 85 = 0.333333
// 0xAA = 170 = 0.6666667
// 0xFF = 255 = 1.0
- (CGFloat) bestColorComponentValue: (CGFloat) colorComponent
{
	if (colorComponent < 0.166666)
	{
		return 0.0; // 0x00
	}
	else if (colorComponent < 0.5)
	{
		return 1.0/3.0; // 0x55
	}
	else if (colorComponent < 0.833333)
	{
		return 2.0/3.0; // 0xAA
	}
	else
	{
		return 1.0; // 0xFF
	}
}

// This comes closer and it adjusts each color to have the proper EGA levels for each color component.
// Each color component is marked at intervals of thirds (0, 1/3, 2/3, 1), which in hex is 0x00, 0x55, 0xAA, 0xFF.
- (NSColor *) closerEGAColor: (NSColor *)pixelColor
{
	CGFloat red = [pixelColor redComponent];
	CGFloat green = [pixelColor greenComponent];
	CGFloat blue = [pixelColor blueComponent];

	// For each color component, need to calculate the closest value
	CGFloat updatedRed = [self bestColorComponentValue: red];
	CGFloat updatedGreen = [self bestColorComponentValue: green];
	CGFloat updatedBlue = [self bestColorComponentValue: blue];
		
	return [NSColor colorWithCalibratedRed: updatedRed green: updatedGreen blue: updatedBlue alpha: 1.0];
}


/// Convert an NSColor and return its hex representation as a string (RRGGBB)
/// @param egaColor The original NSColor to convert into a hex string
- (NSString *) convertNSColorToHex:(NSColor *)egaColor
{
	NSString *hexString = nil;
	
	CGFloat red = [egaColor redComponent];
	CGFloat green = [egaColor greenComponent];
	CGFloat blue = [egaColor blueComponent];
	
	int redInt = (int)(red * 255.0);
	int greenInt = (int)(green * 255.0);
	int blueInt = (int)(blue * 255.0);
	
	hexString = [NSString stringWithFormat:@"%02X%02X%02X", redInt, greenInt, blueInt];
	
	return hexString;
}

/// Calculate and return the closest EGA color to the given pixelColor
/// Note: There are still issues with trying to select a proper EGA color
/// Might need to saturate the colors or determine a better algorithm to
/// choose better colors so things like grass and leaves will be some shade
/// of green instead of grey, black, or brown.
/// @param pixelColor The color of the current pixel
- (NSColor *) closestEGAColor:(NSColor *)pixelColor
{
	NSArray *colorPalette = @[	[NSColor colorWithCalibratedRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0], // 0: Black
							[NSColor colorWithCalibratedRed: 0.0 green: 0.0 blue: 170.0/255.0 alpha: 1.0], // 1: Blue
							[NSColor colorWithCalibratedRed: 0.0 green: 170.0/255.0 blue: 0.0 alpha: 1.0], // 2: Green
							[NSColor colorWithCalibratedRed: 0.0 green: 170.0/255.0 blue: 170.0/255.0 alpha: 1.0], // 3: Cyan
							[NSColor colorWithCalibratedRed: 170.0/255.0 green: 0.0 blue: 0.0 alpha: 1.0], // 4: Red
							[NSColor colorWithCalibratedRed: 170.0/255.0 green: 0.0 blue: 170.0/255.0 alpha: 1.0], // 5: Magenta
							[NSColor colorWithCalibratedRed: 170.0/255.0 green: 85.0/255.0 blue: 0.0 alpha: 1.0], // 6: Brown
							[NSColor colorWithCalibratedRed: 170.0/255.0 green: 170.0/255.0 blue: 170.0/255.0 alpha: 1.0], // 7: Light grey
							[NSColor colorWithCalibratedRed: 85.0/255.0 green: 85.0/255.0 blue: 85.0/255.0 alpha: 1.0], // 8: Dark grey
							[NSColor colorWithCalibratedRed: 85.0/255.0 green: 85.0/255.0 blue: 1.0 alpha: 1.0], // 9: Light blue
							[NSColor colorWithCalibratedRed: 85.0/255.0 green: 1.0 blue: 85.0/255.0 alpha: 1.0], // 10: Light green
							[NSColor colorWithCalibratedRed: 85.0/255.0 green: 1.0 blue: 1.0 alpha: 1.0], // 11: Light cyan
							[NSColor colorWithCalibratedRed: 1.0 green: 85.0/255.0 blue: 85.0/255.0 alpha: 1.0], // 12: Light red
							[NSColor colorWithCalibratedRed: 1.0 green: 85.0/255.0 blue: 1.0 alpha: 1.0], // 13: Light magenta
							[NSColor colorWithCalibratedRed: 1.0 green: 1.0 blue: 85.0/255.0 alpha: 1.0], // 14: Yellow
							[NSColor colorWithCalibratedRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0], // 15: White
						];
	
	// All 64 colors of the full EGA color palette.  Each color is paired up with a matching
	// color in the 16 color palette (above).
	NSDictionary *colorMatch = @{
		@"000000": @0,
		@"000055": @1,
		@"0000AA": @1,
		@"0000FF": @1,
		@"005500": @2,
		@"005555": @8,
		@"0055AA": @1,
		@"0055FF": @9,
		@"00AA00": @2,
		@"00AA55": @2,
		@"00AAAA": @3,
		@"00AAFF": @3,
		@"00FF00": @2,
		@"00FF55": @10,
		@"00FFAA": @3,
		@"00FFFF": @11,
		@"550000": @4,
		@"550055": @8,
		@"5500AA": @1,
		@"5500FF": @9,
		@"555500": @8,
		@"555555": @8,
		@"5555AA": @9,
		@"5555FF": @9,
		@"55AA00": @2,
		@"55AA55": @2,
		@"55AAAA": @3,
		@"55AAFF": @11,
		@"55FF00": @10,
		@"55FF55": @10,
		@"55FFAA": @10,
		@"55FFFF": @11,
		@"AA0000": @4,
		@"AA0055": @4,
		@"AA00AA": @5,
		@"AA00FF": @5,
		@"AA5500": @6,
		@"AA5555": @6,
		@"AA55AA": @5,
		@"AA55FF": @9,
		@"AAAA00": @2, // Originally was set to @6, but trees were too brown
		@"AAAA55": @7,
		@"AAAAAA": @7,
		@"AAAAFF": @7,
		@"AAFF00": @10,
		@"AAFF55": @10,
		@"AAFFAA": @7,
		@"AAFFFF": @11,
		@"FF0000": @4,
		@"FF0055": @12,
		@"FF00AA": @5,
		@"FF00FF": @13,
		@"FF5500": @12,
		@"FF5555": @12,
		@"FF55AA": @12,
		@"FF55FF": @13,
		@"FFAA00": @6,
		@"FFAA55": @14, // Was 12, changed to 14
		@"FFAAAA": @7,
		@"FFAAFF": @13,
		@"FFFF00": @14,
		@"FFFF55": @14,
		@"FFFFAA": @14,
		@"FFFFFF": @15
	};
    
	// Get the normalized color where each RGB component is set to either 0x00, 0x55, 0xAA, or 0xFF
	NSColor *updatedPixelColor = [self closerEGAColor:pixelColor];
	NSString *updatedPixelHexValue = [self convertNSColorToHex:updatedPixelColor];
	NSNumber *colorPaletteIndex = colorMatch[updatedPixelHexValue]; // Find the closest matching color in the 16-color palette

	return colorPalette[[colorPaletteIndex intValue]];
}


/// Create a filter to resize a CIImage
/// @param widthScale The scale for the intended width
/// @param heightScale The scale for the intended height
/// @param image The original image to resize
- (CIFilter *) resizeFilter: (CGFloat)widthScale heightScale: (CGFloat)heightScale image: (CIImage *)image {
	
	// NOTE: https://boredzo.org/blog/archives/2010-02-06/nearest-neighbor-iu also has other examples
	// of nearest neighbor scaling
	CIFilter *resizeFilter = [CIFilter filterWithName:@"CIAffineTransform"];
	NSAffineTransform *affineTransform = [NSAffineTransform transform];
	[affineTransform scaleXBy: widthScale yBy: heightScale];
	[resizeFilter setValue:affineTransform forKey:@"inputTransform"];
	[resizeFilter setValue:image forKey:@"inputImage"];
	
	return resizeFilter;
}

/// De-make an image so it has the appearance of a computer game from the mid-1980s.
/// @param image The original image to de-make
/// @param userObject The user object
- (CIImage *) convert:(CIImage *)image userObject:(id)userObject {
	
	NSBitmapImageRep *initialBitmap = [[NSBitmapImageRep alloc] initWithCIImage: image];
	NSSize initialImageSize = [initialBitmap size];
	CGFloat scale = 320.0/initialImageSize.width;
	
	// Resize the image (retain the original ratio) to a width of 320 pixels
	CIFilter *initialResizeFilter = [self resizeFilter:scale heightScale:scale image:image];
	CIImage *initialResizedImage =  [initialResizeFilter valueForKey:@"outputImage"];
	
	// Squash the image horizontally so it is only 160 pixels in width, but the height is preserved.
	CIFilter *squashedResizeFilter = [self resizeFilter:0.5 heightScale: 1.0 image: initialResizedImage];
	CIImage *resizedImage = [squashedResizeFilter valueForKey:@"outputImage"];
		
	// NOTE: A couple of these CIFilters were used for experimentation and can easily be used in this plug-in.
			
	// Saturation
//	CIFilter *colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
//	[colorControlsFilter setDefaults];
//	[colorControlsFilter setValue: image forKey:@"inputImage"];
//	[colorControlsFilter setValue: [NSNumber numberWithFloat: 2.0] forKey:@"inputSaturation"];
//	[colorControlsFilter setValue: [NSNumber numberWithFloat: 0.0] forKey:@"inputBrightness"];
//	[colorControlsFilter setValue: [NSNumber numberWithFloat: 1.0] forKey:@"inputContrast"];
//	CIImage *saturatedImage = [colorControlsFilter valueForKey:@"outputImage"];
	
	// Apply the Posterize CIFilter to reduce the number of colors
	// Color Posterize
//	CIFilter* posterize = [CIFilter filterWithName:@"CIColorPosterize"];
//	[posterize setDefaults];
//	[posterize setValue:[NSNumber numberWithDouble:4.0] forKey:@"inputLevels"];
//	[posterize setValue:resizedImage forKey:@"inputImage"];
//	CIImage *posterizeResult = [posterize valueForKey:@"outputImage"];
	
	// Cycle through each pixel and find the nearest color and replace it in the standard EGA palette
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCIImage: resizedImage];
	NSSize bitmapSize = [bitmap size];  // Get the size of the bitmap
	int height = (int)bitmapSize.height;
	int width = (int)bitmapSize.width;
	
	// Draw out the updated colors to the resizedBitmap to create the pixelated double-wide pixels look
	// This bitmap is twice the width of resizedImage
    NSBitmapImageRep *resizedBitmap = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
                            pixelsWide:width*2
                            pixelsHigh:height
                         bitsPerSample:8
                       samplesPerPixel:4
                              hasAlpha:YES
                              isPlanar:NO
                        colorSpaceName:NSCalibratedRGBColorSpace
                           bytesPerRow:0
                          bitsPerPixel:0];
    resizedBitmap.size = NSMakeSize(width*2, height);
		
	// Use GCD to help parallelize this, otherwise this is noticeably slooooow
	// https://oleb.net/blog/2013/07/parallelize-for-loops-gcd-dispatch_apply/
	// https://www.objc.io/issues/2-concurrency/low-level-concurrency-apis/
	dispatch_apply(width, dispatch_get_global_queue(0, 0), ^(size_t x) {
		for (size_t y = 0; y < height; y++) {
			// https://ua.reonis.com/index.php?topic=3797.msg54893#msg54893
			// The above link mentions a very similar logic, except it then maps each of the possible 64 colors
			// to a 16 color EGA palette.
			NSColor *originalPixelColor = [bitmap colorAtX:x y:y];
			NSColor *newPixelColor = [self closestEGAColor: originalPixelColor];
			
			// Draw out the double-wide pixel to resizedBitmap
			[resizedBitmap setColor: newPixelColor atX: (2*x) y: y];
			[resizedBitmap setColor: newPixelColor atX: (2*x)+1 y: y];
		}
	});
		
	// Resize the canvas
	id <ACDocument> theDoc = [[NSDocumentController sharedDocumentController] currentDocument];
	NSSize newCanvasSize = NSMakeSize(initialImageSize.width*scale, initialImageSize.height*scale);
	[theDoc setCanvasSize: newCanvasSize];
	
	// Return the modified CIImage
	CIImage *outputImage = [[CIImage alloc] initWithBitmapImageRep: resizedBitmap];
		
	return outputImage;
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

@end
