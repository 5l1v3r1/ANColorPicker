//
//  ANColorPicker.m
//  ANColorPicker
//
//  Created by Alex Nichol on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANColorPicker.h"


@implementation ANColorPicker

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    frame.size.width = 231;
	frame.size.height = 190;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		self.backgroundColor = [UIColor clearColor];
		brightness = [[UIImage imageNamed:@"brightness.png"] retain];
		wheel = [[UIImage imageNamed:@"wheel.png"] retain];
		colorFrame.origin.x = self.frame.size.width - (brightness.size.width / 2.0);
		colorFrame.origin.y = 0;
		colorFrame.size.width = brightness.size.width / 2.0;
		colorFrame.size.height = brightness.size.height / 2.0;
		circleFrame.origin.x = 0;
		circleFrame.origin.y = (self.frame.size.height - (wheel.size.height / 2)) / 2.0;
		circleFrame.size.width = wheel.size.width / 2.0;
		circleFrame.size.height = wheel.size.height / 2.0;
        wheelAdjusted = [[ANImageBitmapRep alloc] initWithImage:wheel];
		selectedPoint.x = circleFrame.size.width;
		selectedPoint.y = circleFrame.size.height;
		brightnessPCT = 1;
		
		[self setBrightness:brightnessPCT];
		
		drawsSquareIndicator = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		
		CGRect frame = self.frame;
		frame.size.width = 231;
		frame.size.height = 190;
		[self setFrame:frame];
		
		self.backgroundColor = [UIColor clearColor];
		brightness = [[UIImage imageNamed:@"brightness.png"] retain];
		wheel = [[UIImage imageNamed:@"wheel.png"] retain];
		colorFrame.origin.x = self.frame.size.width - (brightness.size.width / 2.0);
		colorFrame.origin.y = 0;
		colorFrame.size.width = brightness.size.width / 2.0;
		colorFrame.size.height = brightness.size.height / 2.0;
		circleFrame.origin.x = 0;
		circleFrame.origin.y = (self.frame.size.height - (wheel.size.height / 2)) / 2.0;
		circleFrame.size.width = wheel.size.width / 2.0;
		circleFrame.size.height = wheel.size.height / 2.0;
        wheelAdjusted = [[ANImageBitmapRep alloc] initWithImage:wheel];
		selectedPoint.x = circleFrame.size.width;
		selectedPoint.y = circleFrame.size.height;
		
		brightnessPCT = 1;
		
		drawsSquareIndicator = YES;
		
		if ([aDecoder decodeObjectForKey:@"selectedPoint"]) {
			selectedPoint = CGPointFromString([aDecoder decodeObjectForKey:@"selectedPoint"]);
			drawsBrightnessChanger = [aDecoder decodeBoolForKey:@"drawBright"];
			if (drawsBrightnessChanger)
				[self setBrightness:[aDecoder decodeFloatForKey:@"brightness"]];
			[self setDrawsBrightnessChanger:drawsBrightnessChanger];
		}
		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	// encode ourselves with a nice coder.
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:NSStringFromCGPoint(selectedPoint)
				  forKey:@"selectedPoint"];
	[aCoder encodeFloat:[self brightness]
				  forKey:@"brightness"];
	[aCoder encodeBool:drawsBrightnessChanger forKey:@"drawBright"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint p = [[touches anyObject] locationInView:self];
	if (CGRectContainsPoint(colorFrame, p)) {
		CGPoint colorP = p;
		colorP.x -= colorFrame.origin.x;
		colorP.y -= colorFrame.origin.y;
		brightnessPCT = colorFrame.size.height - colorP.y;
		brightnessPCT /= colorFrame.size.height;
		
		[self setBrightness:brightnessPCT];
	} else if (CGRectContainsPoint(circleFrame, p)) {
		CGPoint colorP = p;
		colorP.x -= circleFrame.origin.x;
		colorP.y -= circleFrame.origin.y;
		colorP.x *= 2;
		colorP.y *= 2;
		
		
        BMPixel pixel = [wheelAdjusted getPixelAtPoint:BMPointMake(colorP.x, colorP.y)];
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if (pixel.alpha > 0.9) {
			pixel.alpha = 1.0;
			selectedPoint.x = colorP.x;
			selectedPoint.y = colorP.y;
            
            UIColor *newColor = [UIColor colorWithRed:pixel.red green:pixel.green blue:pixel.blue alpha:pixel.alpha];
			[lastColor release];
			lastColor = [newColor retain];
			[delegate colorChanged:newColor];
		}
		[pool drain];
		[self setNeedsDisplay];
	}
}

#pragma mark Custom Getters and Setters

- (void)setBrightness:(float)_brightness {
	// manually adjust the brightness
	// by getting the pixel and such, then
	// send the message to our delegate
	
	[wheelAdjusted release];
    ANImageBitmapRep *newImage = [[ANImageBitmapRep alloc] initWithImage:wheel];
	brightnessPCT = _brightness;
	[newImage setBrightness:brightnessPCT];
	wheelAdjusted = newImage;
	
	// get the color that we have selected, and apply our brightness.
	// then send a nice color message.
    BMPixel pixel = [wheelAdjusted getPixelAtPoint:BMPointMake(selectedPoint.x, selectedPoint.y)];
	// use autorelease so that our autoreleased colors
	// do in fact get released.
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (pixel.alpha > 0.9) {
		pixel.alpha = 1.0;
        
        UIColor *newColor = [UIColor colorWithRed:pixel.red green:pixel.green blue:pixel.blue alpha:pixel.alpha];
		[lastColor release];
		lastColor = [newColor retain];
		[delegate colorChanged:newColor];
	}
	[pool drain];
	[self setNeedsDisplay];
}
- (float)brightness {
	return brightnessPCT;
}

- (BOOL)drawsBrightnessChanger {
	return drawsBrightnessChanger;
}

- (void)setDrawsBrightnessChanger:(BOOL)b {
	drawsBrightnessChanger = b;
	if (!b) {
		circleFrame.origin.x = self.frame.size.width / 2 - (circleFrame.size.width / 2);
	} else {
		circleFrame.origin.x = 0;
		circleFrame.origin.y = (self.frame.size.height - (wheel.size.height / 2)) / 2.0;
		circleFrame.size.width = wheel.size.width / 2.0;
		circleFrame.size.height = wheel.size.height / 2.0;
	}
	[self setNeedsDisplay];
}

- (BOOL)drawsSquareIndicator {
	return drawsSquareIndicator;
}
- (void)setDrawsSquareIndicator:(BOOL)b {
	drawsSquareIndicator = b;
	[self setNeedsDisplay];
}

- (UIColor *)color {
	return lastColor;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
	// Draw the two parts of the picker
	if (drawsBrightnessChanger)
		[brightness drawInRect:colorFrame];
	[[wheelAdjusted image] drawInRect:circleFrame];
	
	// draw a square around selected point
	if (drawsSquareIndicator) {
		CGPoint selPoint = selectedPoint;
		selPoint.x /= 2;
		selPoint.y /= 2;
		selPoint.x += circleFrame.origin.x;
		selPoint.y += circleFrame.origin.y;
		
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSetStrokeColorWithColor(ctx, [[UIColor blackColor] CGColor]);
		CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
		CGContextStrokeRect(ctx, CGRectMake(selPoint.x - 4, selPoint.y - 4, 8, 8));
		CGContextFillRect(ctx, CGRectMake(selPoint.x - 4, selPoint.y - 4, 8, 8));
	}
}


- (void)dealloc {
	[wheel release];
	[brightness release];
	[wheelAdjusted release];
	[lastColor release];
    [super dealloc];
}


@end
