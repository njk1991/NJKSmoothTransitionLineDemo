//
//  ViewController.m
//  NJKSmoothTransitionDemo
//
//  Created by JiakaiNong on 15/12/2.
//  Copyright © 2015年 poco. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIImage *viewImage;

@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (assign, nonatomic) CGPoint fromPoint;
@property (assign, nonatomic) CGPoint toPoint;

@property (assign, nonatomic) CGFloat startLineWidth;
@property (assign, nonatomic) CGFloat endLineWidth;

@property (assign, nonatomic) CGPoint currentPoint;
@property (assign, nonatomic) CGPoint previousPoint;
@property (assign, nonatomic) CGFloat currentSpeed;
@property (assign, nonatomic) CGFloat previousSpeed;
@property (assign, nonatomic) NSTimeInterval previousTimestamp;

@end

@implementation ViewController

static CGFloat kMaxLineWidth = 10;
static CGFloat kMinLineWidth = 3;
static CGFloat kSamplingDistance = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
}

- (void)drawLine {
    CGFloat dX = (self.endPoint.x - self.startPoint.x);
    CGFloat dY = (self.endPoint.y - self.startPoint.y);
    
    CGFloat distance = sqrt(pow(dX, 2) + pow(dY, 2));
    
    NSInteger dotCount = distance / (MIN(self.startLineWidth, self.endLineWidth));
    //        NSInteger dotCount = 10;
    
    CGFloat factor = 1 / ((CGFloat)dotCount + 1);
    CGFloat deltaX = dX * factor;
    CGFloat deltaY = dY * factor;
    CGFloat deltaWidth = (self.endLineWidth - self.startLineWidth) * factor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(self.endPoint.x - self.endLineWidth / 2, self.endPoint.y - self.endLineWidth / 2, self.endLineWidth, self.endLineWidth));
    
    for (int i = 0; i < dotCount + 1; i++) {
        if (i == 0) {
            self.fromPoint = self.startPoint;
        }
        if (i == dotCount + 1) {
            self.toPoint = self.endPoint;
        }
        self.toPoint = CGPointMake(self.fromPoint.x + deltaX, self.fromPoint.y + deltaY);
        self.startLineWidth += deltaWidth;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, self.fromPoint.x, self.fromPoint.y);
        CGContextAddLineToPoint(context, self.toPoint.x,self.toPoint.y);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        CGContextSetLineWidth(context, self.startLineWidth);
        CGContextSetAlpha(context, 0.5f);
        CGContextStrokePath(context);
        self.fromPoint = self.toPoint;
    }
    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
    self.view.layer.contents = (id)self.viewImage.CGImage;
}

#pragma mark - TouchesMethods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.previousTimestamp = event.timestamp;
    self.endPoint = [[touches anyObject] locationInView:self.view];
    self.startPoint = self.endPoint;
    self.startLineWidth = kMaxLineWidth;
    self.endLineWidth = self.startLineWidth;
    [self drawLine];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.endPoint = [[touches anyObject] locationInView:self.view];
    CGFloat dx = ABS(self.endPoint.x - self.startPoint.x);
    CGFloat dy = ABS(self.endPoint.y - self.startPoint.y);
    self.currentSpeed = sqrt(pow(dx, 2) + pow(dy, 2)) / (event.timestamp - self.previousTimestamp) / 1000;
    if (dx > kSamplingDistance || dy > kSamplingDistance) {
        self.endLineWidth = MAX(kMinLineWidth, kMaxLineWidth - self.currentSpeed);
        [self drawLine];
        self.previousTimestamp = event.timestamp;
        self.startPoint = self.endPoint;
        self.startLineWidth = self.endLineWidth;
        self.previousSpeed = self.currentSpeed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!CGPointEqualToPoint(self.endPoint, [[touches anyObject] locationInView:self.view])) {
        self.endPoint = [[touches anyObject] locationInView:self.view];
        [self drawLine];
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    self.viewImage = nil;
    self.view.layer.contents = nil;
    CGContextClearRect(UIGraphicsGetCurrentContext(), self.view.bounds);
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    UIGraphicsEndImageContext();
}

@end
