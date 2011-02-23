//
//  ANColorPickerViewController.m
//  ANColorPicker
//
//  Created by Alex Nichol on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANColorPickerViewController.h"

@implementation ANColorPickerViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)colorChanged:(UIColor *)newColor {
	[colorView setBackgroundColor:newColor];
	[brightness setValue:[picker brightness]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
	NSString * coderPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/save.dat"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:coderPath]) {
		// we can load from a coder
		picker = [[NSKeyedUnarchiver unarchiveObjectWithFile:coderPath] retain];
	} else {
		picker = [[ANColorPicker alloc] initWithFrame:CGRectMake(0, 0, 231, 190)];
	}
	
	[picker setDelegate:self];
	picker.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
	[self.view addSubview:picker];
	CGRect frm = picker.frame;
	frm.origin.y += frm.size.height + 20;
	frm.size.height = 60;
	
	colorView = [[UIView alloc] initWithFrame:frm];
	[colorView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:[colorView autorelease]];
	// set the initial color
	[colorView setBackgroundColor:[picker color]];
	[picker setDrawsBrightnessChanger:YES];
	
	[brightness setValue:[picker brightness]];
}

- (IBAction)brightnessChange:(id)sender {
	[picker setBrightness:[brightness value]];
}

- (void)saveState {
	NSLog(@"Save state.");
	NSString * coderPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/save.dat"];
	[NSKeyedArchiver archiveRootObject:picker 
								toFile:coderPath];
	NSLog(@"Done.");
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[picker release];
    [super dealloc];
}

@end
