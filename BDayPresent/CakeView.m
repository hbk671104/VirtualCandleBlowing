//
//  CakeView.m
//  BDayPresent
//
//  Created by BK on 12/15/14.
//  Copyright (c) 2014 Bokang Huang. All rights reserved.
//

#import "CakeView.h"

@implementation CakeView

@synthesize flame1, flame2, cake;

- (id)initWithFrame:(CGRect)frame {
	
	if ([super initWithFrame:frame]) {
		
		// Cake
		self.cake = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cake"]];
		self.cake.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		self.cake.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:self.cake];
		
		// Two flame
		self.flame1 = [[FlameView alloc] initWithFrame:CGRectMake(frame.size.width * 0.22, frame.size.height * 0.02, frame.size.width * 0.08, frame.size.height * 0.12)];
		self.flame2 = [[FlameView alloc] initWithFrame:CGRectMake(frame.size.width * 0.66, frame.size.height * 0.02, frame.size.width * 0.08, frame.size.height * 0.12)];		
		[self addSubview:self.flame1];
		[self addSubview:self.flame2];
		
	}
	
	return self;
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
