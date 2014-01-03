//
//  CircleCounterView.m
//  CircleCountDown
//
//  Created by Haoxiang Li on 11/25/11.
//  Copyright (c) 2011 DEV. All rights reserved.
//

#import "CircleCounterView.h"

#define kCircleSegs 30

@interface CircleCounterView ()
@property (nonatomic, retain) NSString *timeFormatString;

- (void)setup;
- (void)update:(id)sender;
- (void)updateTime:(id)sender;

@end

@implementation CircleCounterView
@synthesize numberColor = mNumberColor;
@synthesize numberFont = mNumberFont;
@synthesize circleColor = mCircleColor;
@synthesize circleBorderWidth = mCircleBorderWidth;
@synthesize timeFormatString = mTimeFormatString;
@synthesize circleIncre = mCircleIncre;
@synthesize circleTimeInterval = mCircleTimeInterval;
@synthesize delegate = mDelegate;
@synthesize timerStart;
@synthesize timerValue;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}
                      
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    
    self.numberFont = nil;
    self.numberColor = nil;
    self.circleColor = nil;
    self.circleBorderWidth = 0;
    self.timeFormatString = nil;
    
}

- (void)drawRect:(CGRect)rect {

    mCircleSegs = timerValue / timerStart;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float radius = CGRectGetWidth(rect)/2.0f - self.circleBorderWidth/2.0f;
    float angleOffset = M_PI_2;
    
    CGContextSetLineWidth(context, self.circleBorderWidth);
    CGContextBeginPath(context);
    //NSLog(@"Current Angle = %0.1f",mCircleSegs);
    if (self.circleIncre)
    {
       /* CGContextAddArc(context, 
                        CGRectGetMidX(rect), CGRectGetMidY(rect),
                        radius, 
                        -angleOffset, 
                        (mCircleSegs + 1)/(float)kCircleSegs*M_PI*2 - angleOffset, 
                        0);*/
        CGContextAddArc(context, 
                        CGRectGetMidX(rect), CGRectGetMidY(rect),
                        radius, 
                        -angleOffset, 
                        mCircleSegs*M_PI*2 - angleOffset, 
                        0);
    }
    else
    {
        /*CGContextAddArc(context, 
                        CGRectGetMidX(rect), CGRectGetMidY(rect),
                        radius, 
                        (mCircleSegs + 1)/(float)kCircleSegs*M_PI*2 - angleOffset, 
                        2*M_PI - angleOffset, 
                        0);*/
        CGContextAddArc(context, 
                        CGRectGetMidX(rect), CGRectGetMidY(rect),
                        radius, 
                        mCircleSegs*M_PI*2 - angleOffset, 
                        2*M_PI - angleOffset, 
                        0);
    }
    
    // Set the color based on the amount of time remaining
    float colorRed = 0;
    float colorGreen = 0;
    float colorBlue = 0;
    
    float colorRegime = fabsf(mCircleSegs -1.0f);
    
    if (colorRegime < 0.16667f) {
        colorBlue = 1.0f;
        colorGreen = 0;
        colorRed = 0;
    } else if (colorRegime < 0.3333f) {
        colorBlue = 1.0f;
        colorGreen = -1.0f + 6.0f * colorRegime;
        colorRed = 0;
    } else if  (colorRegime < 0.5f) {
        colorBlue = 2.0f - 3.0f * colorRegime;
        colorGreen = 1.0f;
        colorRed = -1.0f + 3.0f * colorRegime;
    } else if  (colorRegime < 0.6667f) {
        colorBlue = 2.0f - 3.0f * colorRegime;
        colorGreen = 1.0f;
        colorRed = -1.0f + 3.0f * colorRegime;
    } else if  (colorRegime < 0.83333f) {
        colorRed = 1.0f;
        colorGreen = 5.0f - 6.0f * colorRegime;
        colorBlue = 0;
    } else {
        colorRed = 1.0f;
        colorGreen = 0;
        colorBlue = 0;
    }
    
    //[UIColor colorWithRed:colorRed green:colorGreen blue:colorBlue alpha:1.0];
    //CGContextSetStrokeColorWithColor(context, self.circleColor.CGColor);
    //CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:colorRed green:colorGreen blue:colorBlue alpha:1.0].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextStrokePath(context);
    [[UIColor darkGrayColor] setFill];
    CGContextSetLineWidth(context, 1.0f);
    NSString *numberText = [NSString stringWithFormat:self.timeFormatString, timerValue];
    CGSize sz = [numberText sizeWithFont:self.numberFont];
    [numberText drawInRect:CGRectInset(rect, (CGRectGetWidth(rect) - sz.width)/2.0f, (CGRectGetHeight(rect) - sz.height)/2.0f)
                  withFont:self.numberFont];
}

- (void)setup {
    
    mIsRunning = NO;
    
    //< Default Parameters
    self.numberColor = [UIColor darkGrayColor];
    self.numberFont = [UIFont fontWithName:@"Helvetica-Bold" size:40.0f];
    self.circleColor = [UIColor blackColor];
    self.circleBorderWidth = 20;
    self.timeFormatString = @"%.0f";
    self.circleIncre = YES;
    self.circleTimeInterval = 0.1f;
        
    mTimeInSeconds = 20;
    mTimeInterval = 1;
    mCircleSegs = 0;
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Public Methods
- (void)startWithSeconds:(float)seconds andInterval:(float)interval andTimeFormat:(NSString *)timeFormat {
  /*  self.timeFormatString = timeFormat;
    [self startWithSeconds:seconds andInterval:interval];*/
}

- (void)startWithSeconds:(float)seconds andInterval:(float)interval {
   /* if (interval > seconds)
    {
        mTimeInterval = seconds/10.0f;
    }
    else
    {
        mTimeInterval = interval;
    }
    
    [self startWithSeconds:seconds];*/
}

- (void)startWithSeconds:(float)seconds {
  /*  if (seconds > 0)
    {
        startSeconds = seconds;
        mTimeInSeconds = seconds;
        mIsRunning = YES;
        mCircleSegs = 0;
        [self update:nil];
        [self updateTime:nil];
    }*/
}

- (void)stop {
    mIsRunning = NO;
}

#pragma mark - Private Methods
- (void)update:(id)sender {
  /*  if (mIsRunning)
    {
        //mCircleSegs = (mCircleSegs + 1) % kCircleSegs;
        mCircleSegs = mTimeInSeconds / startSeconds;
        //NSLog(@"mTimeInSeconds = %0.1f, startSeconds = %0.1f", mTimeInSeconds, startSeconds);
        if (fabs(mTimeInSeconds) < 1e-4)
        {
            //< Finished
            //mCircleSegs = (kCircleSegs - 1);
            mCircleSegs = 1;
            mTimeInSeconds = 0;
            [self.delegate counterDownFinished:self];
        }
        else
        {
            [NSTimer scheduledTimerWithTimeInterval:self.circleTimeInterval
                                             target:self
                                           selector:@selector(update:) 
                                           userInfo:nil
                                            repeats:NO];
        }
        [self setNeedsDisplay];
    }*/
}

- (void)updateTime:(id)sender {
   /* if (mIsRunning)
    {
        mTimeInSeconds -= mTimeInterval;
        if (fabs(mTimeInSeconds) < 1e-4)
        {
            //< Finished
            mCircleSegs = (kCircleSegs - 1);
            mTimeInSeconds = 0;
            [self.delegate counterDownFinished:self];
        }
        else
        {            
            [NSTimer scheduledTimerWithTimeInterval:mTimeInterval
                                             target:self 
                                           selector:@selector(updateTime:)
                                           userInfo:nil
                                            repeats:NO];
        }
    }*/
}

@end
