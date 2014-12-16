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
#import <Canvas/Canvas.h>

@interface ViewController ()

@property (strong, nonatomic) CakeView *cakeView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) CSAnimationView *topAnimationView, *bottomAnimationView;

@end

@implementation ViewController {

	double lowPassResults;
	BOOL blowTriggered;
	
	CGRect viewBounds;
	
}

@synthesize recorder;
@synthesize levelTimer;
@synthesize cakeView;
@synthesize topAnimationView, bottomAnimationView;
@synthesize label;

- (id) init {
	
	if ([super init]) {
		
		// Sound did finish playing notification
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(soundDidFinishPlaying:)
													 name:SoundDidFinishPlayingNotification
												   object:nil];
		
	}
	
	return self;
	
}

- (void)viewDidLoad {
	
	[super viewDidLoad];

	viewBounds = self.view.layer.bounds;
	
	// Top and bottom animation view
	topAnimationView = [[CSAnimationView alloc] initWithFrame:CGRectMake(0,
																		 0,
																		 viewBounds.size.width,
																		 viewBounds.size.height/3.0)];
	bottomAnimationView = [[CSAnimationView alloc] initWithFrame:CGRectMake(0,
																			viewBounds.size.height/3.0,
																			viewBounds.size.width,
																			viewBounds.size.height*2/3.0)];
	
	// Add cake view to botton animation view
	self.cakeView = [[CakeView alloc] initWithFrame:CGRectMake(0,
															   0,
															   bottomAnimationView.frame.size.width,
															   bottomAnimationView.frame.size.height)];
	[bottomAnimationView addSubview:self.cakeView];
	
	bottomAnimationView.duration = 0.5;
	bottomAnimationView.delay = 0;
	bottomAnimationView.type = CSAnimationTypeBounceUp;
	
	[self.view addSubview:topAnimationView];
	[self.view addSubview:bottomAnimationView];
	[bottomAnimationView startCanvasAnimation];
	
	// Birthday sound
	[SoundManager sharedManager].allowsBackgroundMusic = YES;
	[[SoundManager sharedManager] prepareToPlayWithSound:@"birthdaySong.aiff"];
	[[SoundManager sharedManager] setSoundVolume:0.5];
	[[SoundManager sharedManager] setSoundFadeDuration:0.5];
	[[SoundManager sharedManager] playSound:@"birthdaySong.aiff" looping:NO fadeIn:YES];
	
}

- (void) soundDidFinishPlaying:(NSNotification *) notification {
	
	// [notification name] should always be @"TestNotification"
	// unless you use this method for observation of other notifications
	// as well.
	
	if ([[notification name] isEqualToString:SoundDidFinishPlayingNotification]) {
		
		NSLog(@"Sound finished playing!");
		
		// Fire blow detection
		[self setUpBlowDetection];
		
		// Display blow instruction
		topAnimationView.duration = 0.5;
		topAnimationView.delay = 0;
		topAnimationView.type = CSAnimationTypeBounceDown;
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0,
														  0,
														  topAnimationView.frame.size.width,
														  topAnimationView.frame.size.height)];
		label.text = @"Blow into the mic to put out the candles:)";
		label.numberOfLines = 0;
		label.font = [UIFont systemFontOfSize:viewBounds.size.width * 0.1];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [UIColor whiteColor];
		
		[topAnimationView addSubview:label];
		[topAnimationView startCanvasAnimation];
		
	}
	
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
		[recorder stop];
		
		// Fade out the cakeview
		bottomAnimationView.type = CSAnimationTypeFadeOut;
		bottomAnimationView.delay = 1.0;
		bottomAnimationView.duration = 0.5;
		
		[bottomAnimationView startCanvasAnimation];

		double delayInSeconds = 1.5;
		dispatch_time_t sleepTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(sleepTime, dispatch_get_main_queue(), ^(void){
			
			// Remove cake view
			[self.cakeView removeFromSuperview];
			
			bottomAnimationView.type = CSAnimationTypeFadeIn;
			bottomAnimationView.delay = 0;
			bottomAnimationView.duration = 1.0;
			
			UIImageView *pikachu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pikachu"]];
			pikachu.frame = CGRectMake(0,
									   0,
									   bottomAnimationView.frame.size.width,
									   bottomAnimationView.frame.size.height);
			pikachu.contentMode = UIViewContentModeScaleAspectFit;
			UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc]
											  initWithTarget:self
											  action:@selector(animatePikachu)];
			pikachu.userInteractionEnabled = YES;
			pikachu.gestureRecognizers = @[newTap];
			
			[bottomAnimationView addSubview:pikachu];
			[bottomAnimationView startCanvasAnimation];
			
			double delayInSeconds = 1.0;
			dispatch_time_t sleepTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(sleepTime, dispatch_get_main_queue(), ^(void){
			
				topAnimationView.type = CSAnimationTypeSlideDown;
				topAnimationView.delay = 0;
				topAnimationView.duration = 1.0;
				
				label.text = @"Happy Birthday Grace:)";
				
				[topAnimationView startCanvasAnimation];
				
			});
			
		});
		 
	}
	
}

- (void) animatePikachu {
	
	bottomAnimationView.type = CSAnimationTypeMorph;
	bottomAnimationView.delay = 0;
	bottomAnimationView.duration = 1.0;
	
	[bottomAnimationView startCanvasAnimation];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
