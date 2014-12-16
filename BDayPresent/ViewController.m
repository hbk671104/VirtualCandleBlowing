//
//  ViewController.m
//  BDayPresent
//
//  Created by BK on 11/30/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import "ViewController.h"
#import "CakeView.h"
#import "SoundManager.h"

@interface ViewController ()

@property (strong, nonatomic) CakeView *cakeView;

@end

@implementation ViewController {

	double lowPassResults;
	BOOL blowTriggered;
	
}

@synthesize recorder;
@synthesize levelTimer;
@synthesize cakeView;

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self setUpBlowDetection];
	
	CGRect viewBounds = self.view.layer.bounds;
	self.cakeView = [[CakeView alloc] initWithFrame:CGRectMake(0,
															   viewBounds.size.height/3.0,
															   viewBounds.size.width,
															   viewBounds.size.height*2/3.0)];
	[self.view addSubview:self.cakeView];
	
	// Birthday sound
	[SoundManager sharedManager].allowsBackgroundMusic = YES;
	[[SoundManager sharedManager] prepareToPlayWithSound:@"birthdaySong.aiff"];
	
	[[SoundManager sharedManager] playSound:@"birthdaySong.aiff" looping:NO fadeIn:YES];
	
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
		
		// Remove fire emitter
		[cakeView.flame1.fireEmitter removeFromSuperlayer];
		[cakeView.flame2.fireEmitter removeFromSuperlayer];
		
		blowTriggered = YES;
		
	}
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
