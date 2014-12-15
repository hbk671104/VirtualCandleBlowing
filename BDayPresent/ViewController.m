//
//  ViewController.m
//  BDayPresent
//
//  Created by BK on 11/30/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import "ViewController.h"
#import "FlameView.h"

@interface ViewController ()

@end

@implementation ViewController {

	double lowPassResults;
	BOOL blowTriggered;
	
}

@synthesize recorder;
@synthesize levelTimer;

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self setUpBlowDetection];
	
	CGRect viewBounds = self.view.layer.bounds;
	FlameView *flameView = [[FlameView alloc] initWithFrame:CGRectMake(viewBounds.size.width/2.0 - 10, viewBounds.size.height/2.0 - 10, 20, 20)];
	[self.view addSubview:flameView];
	
}

- (void)setUpBlowDetection {
	
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
