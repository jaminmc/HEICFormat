//
// HEIC format write support plug-in for Adobe Photoshop
// Copyright (c) 2021 jdp.
// Distributed under GPLv3 license.
//

#import "HEIC_UI_Controller.h"

#include "HEIC_log.h"

NSString* kKeyHEICQuality = @"HEIC_Quality";
NSString* kKeyHEICSaveExif = @"HEIC_SaveExif";
NSString* kKeyHEICSaveXmp = @"HEIC_SaveXmp";
NSString* kKeyHEICRevealInFinder = @"HEIC_RevealInFinder";
NSString* kKeyHEICQuiet = @"HEIC_Quiet";
NSString* kKeyHEICConvertToSRGB = @"HEIC_ConvertToSRGB";
NSString* kVendorDomain = @"com.jdp.heic";

void loadOptions(HEICParam* opt) {
    NSUserDefaults* def = [[NSUserDefaults alloc] initWithSuiteName:kVendorDomain];
    [def registerDefaults:@{
        kKeyHEICQuality : @55,
        kKeyHEICSaveExif : @YES,
        kKeyHEICSaveXmp : @YES,
        kKeyHEICRevealInFinder : @NO,
        kKeyHEICQuiet : @NO,
        kKeyHEICConvertToSRGB : @NO,
    }];

    opt->quality = [def integerForKey:kKeyHEICQuality];
    opt->saveExif = [def boolForKey:kKeyHEICSaveExif];
    opt->saveXmp = [def boolForKey:kKeyHEICSaveXmp];
    opt->revealInFinder = [def boolForKey:kKeyHEICRevealInFinder];
    opt->quiet = [def boolForKey:kKeyHEICQuiet];
    opt->convertToSRGB = [def boolForKey:kKeyHEICConvertToSRGB];
    
    // Per-export options (not saved in preferences)
    opt->saveTransparency = YES;  // Default to YES
    opt->hasAlpha = NO;           // Will be set by the caller

    if (opt->quality < 1 || opt->quality > 100) opt->quality = 50;
    
    [def release];
}

void saveOptions(const HEICParam* opt) {
    NSUserDefaults* def = [[NSUserDefaults alloc] initWithSuiteName:kVendorDomain];
    [def setInteger:opt->quality forKey:kKeyHEICQuality];
    [def setBool:opt->saveExif forKey:kKeyHEICSaveExif];
    [def setBool:opt->saveXmp forKey:kKeyHEICSaveXmp];
    [def setBool:opt->revealInFinder forKey:kKeyHEICRevealInFinder];
    [def setBool:opt->quiet forKey:kKeyHEICQuiet];
    [def setBool:opt->convertToSRGB forKey:kKeyHEICConvertToSRGB];
    // Note: saveTransparency is NOT saved - it's a per-export decision
    [def release];
}

@implementation HEIC_UI_Controller

- (id)init {
	self = [super init];
    if (!self) {
        return nil;
    }

    // Get the plugin bundle
    NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
    if (!pluginBundle) {
        xlog("HEIC_UI_Controller: ERROR - Could not get plugin bundle\n");
        [self release];
        return nil;
    }
    
    // Load the NIB file
    // In MRC, loadNibNamed returns an autoreleased array, and the objects in it are also autoreleased
    // We MUST retain the array to keep all objects alive
    NSArray *nibObjects = nil;
    if (![pluginBundle loadNibNamed:@"HEIC_UI" owner:self topLevelObjects:&nibObjects]) {
        xlog("HEIC_UI_Controller: ERROR - Failed to load NIB\n");
        [self release];
        return nil;
    }
    
    // Retain the top-level objects - this keeps everything alive
    topLevelObjects = [nibObjects retain];
    
    if (!theWindow) {
        xlog("HEIC_UI_Controller: ERROR - Window outlet not connected\n");
        [topLevelObjects release];
        topLevelObjects = nil;
        [self release];
        return nil;
    }

    // Load saved options
    HEICParam opt;
    loadOptions(&opt);

    // Set UI values
    [qualityEdit setIntegerValue:opt.quality];
    [quantizeSlider setIntegerValue:opt.quality];
    [saveTransparencyCheckbox setState:opt.saveTransparency ? NSControlStateValueOn : NSControlStateValueOff];
    [saveExifCheckbox setState:opt.saveExif ? NSControlStateValueOn : NSControlStateValueOff];
    [saveXmpCheckbox setState:opt.saveXmp ? NSControlStateValueOn : NSControlStateValueOff];
    [revealInFinderCheckbox setState:opt.revealInFinder ? NSControlStateValueOn : NSControlStateValueOff];
    [quietCheckbox setState:opt.quiet ? NSControlStateValueOn : NSControlStateValueOff];
    [convertToSRGBCheckbox setState:opt.convertToSRGB ? NSControlStateValueOn : NSControlStateValueOff];

    [self trackQuantQuality:self];
	[theWindow center];
    theResult = DIALOG_RESULT_INVALID;
    
	return self;
}

- (void)dealloc {
    // Release the top-level objects array
    [topLevelObjects release];
    topLevelObjects = nil;
    
    [super dealloc];
}

- (IBAction)clickedOK:(id)sender {
    HEICParam opt;
    opt.quality = [qualityEdit integerValue];
    opt.saveTransparency = [saveTransparencyCheckbox state] == NSControlStateValueOn;
    opt.saveExif = [saveExifCheckbox state] == NSControlStateValueOn;
    opt.saveXmp = [saveXmpCheckbox state] == NSControlStateValueOn;
    opt.revealInFinder = [revealInFinderCheckbox state] == NSControlStateValueOn;
    opt.quiet = [quietCheckbox state] == NSControlStateValueOn;
    opt.convertToSRGB = [convertToSRGBCheckbox state] == NSControlStateValueOn;
    
    saveOptions(&opt);
    
	theResult = DIALOG_RESULT_OK;
    [NSApp stopModal];
}

- (IBAction)clickedCancel:(id)sender {
    theResult = DIALOG_RESULT_CANCEL;
    [NSApp stopModal];
}

- (DialogResult)getResult {
	return theResult;
}

- (IBAction)trackQuantQuality:(id)sender {
	NSInteger quality = [quantizeSlider integerValue];
    NSString* quality_string = [NSString stringWithFormat:@"Quality: %ld", (long)quality];
	[sliderLabel setStringValue:quality_string];
    [qualityEdit setIntegerValue:quality];
}

- (IBAction)trackQualityValue:(id)sender {
    NSInteger q = [qualityEdit integerValue];
    if (q < 0 || q > 100) {
        [qualityEdit setIntegerValue:55];
        q = 55;
    }

    [quantizeSlider setIntegerValue:q];
    [self trackQuantQuality:sender];
}

- (NSWindow *)getWindow {
    return theWindow;
}

- (void)setHasAlpha:(BOOL)hasAlpha {
    // Hide and disable the transparency checkbox if no alpha is available
    if (!hasAlpha) {
        [saveTransparencyCheckbox setEnabled:NO];
        [saveTransparencyCheckbox setState:NSControlStateValueOff];
        [saveTransparencyCheckbox setHidden:YES];
    } else {
        [saveTransparencyCheckbox setEnabled:YES];
        [saveTransparencyCheckbox setHidden:NO];
    }
}

@end
