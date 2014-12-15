//
//  FlameView.h
//  BDayPresent
//
//  Created by BK on 12/15/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlameView : UIView

@property (strong) CAEmitterLayer *fireEmitter;
@property (strong) CAEmitterLayer *smokeEmitter;

- (void) setFireAmount:(float)zeroToOne;

@end
