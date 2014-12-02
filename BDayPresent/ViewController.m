//
//  ViewController.m
//  BDayPresent
//
//  Created by BK on 11/30/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface ViewController ()

@end

@implementation ViewController {
	
	AVAudioRecorder *recorder;
	NSTimer *levelTimer;
	double lowPassResults;
	
	BOOL blowTriggered;
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
	
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
	NSError *error;
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	
	if (recorder) {
		[recorder prepareToRecord];
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
		[[AVAudioSession sharedInstance] setActive:YES error:nil];
		recorder.meteringEnabled = YES;
		[recorder record];
		levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
													  target:self
													selector:@selector(levelTimerCallback:)
													userInfo:nil
													 repeats:YES];
	} else
		NSLog(@"error %@",[error description]);
	
	// Haven't blowed yet
	// 想到了邪恶的事情。。。。
	blowTriggered = NO;
	
}

- (void)levelTimerCallback:(NSTimer *)timer {
	
	[recorder updateMeters];
	
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
	
	if (lowPassResults > 0.95 && !blowTriggered) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
														message:@"Blow detected!"
													   delegate:self
											  cancelButtonTitle:@"Yes!"
											  otherButtonTitles:nil, nil];
		[alert show];
		blowTriggered = YES;
	}
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
