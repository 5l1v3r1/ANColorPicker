//
//  ANColorPicker.h
//  ANColorPicker
//
//  Created by Alex Nichol on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANImageBitmapRep.h"

@protocol ANColorPickerDelegate
- (void)colorChanged:(UIColor *)newColor;
@end


@interface ANColorPicker : UIView {
	UIImage *wheel;
	UIImage *brightness;
	UIColor *lastColor;
	ANImageBitmapRep *wheelAdjusted;
	CGRect colorFrame;
	CGRect circleFrame;
	float brightnessPCT;
	CGPoint selectedPoint;
	id<ANColorPickerDelegate> delegate;
	BOOL drawsSquareIndicator;
	BOOL drawsBrightnessChanger;
}

@property (nonatomic, assign) id <ANColorPickerDelegate> delegate;
@property (readwrite) BOOL drawsSquareIndicator;
@property (readwrite) BOOL drawsBrightnessChanger;

-(void)encodeWithCoder:(NSCoder*)aCoder;

-(UIColor*)color;
-(void)setBrightness:(float)_brightness;
-(float)brightness;


@end
