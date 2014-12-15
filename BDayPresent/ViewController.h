//
//  ViewController.h
//  BDayPresent
//
//  Created by BK on 11/30/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) NSTimer *levelTimer;

@end

