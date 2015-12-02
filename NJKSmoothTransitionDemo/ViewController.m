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

- (void)viewDidLoad {
    [super viewDidLoad];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextSetLineJoin(context, kCGLineJoinRound);
//    NSArray *array = [self array];
//    NSArray *speedArray = [self speedArray];
//    [self drawLineWithPoints:array pointsSpeed:speedArray context:context];
//    [self.view setNeedsDisplay];
}

//- (void)drawLineWithPoints:(NSArray *)points pointsSpeed:(NSArray *)pointsSpeed context:(CGContextRef)context {
//    for (int j = 0; j < points.count; j++) {
//        self.endPoint = [points[j] CGPointValue];
//        self.endLineWidth = [pointsSpeed[j] floatValue];
////        CGFloat lineWidth = [pointsSpeed[j] floatValue];
//        if (j == 0) {
//            self.startPoint = self.endPoint;
//            self.startLineWidth = self.endLineWidth;
//        }
//        CGFloat dX = (self.endPoint.x - self.startPoint.x);
//        CGFloat dY = (self.endPoint.y - self.startPoint.y);
//        
//        CGFloat distance = sqrt(pow(dX, 2) + pow(dY, 2));
//        
//        NSInteger dotCount = distance / (MIN(self.startLineWidth, self.endLineWidth));
////        NSInteger dotCount = 10;
//        
//        CGFloat factor = 1 / ((CGFloat)dotCount + 1);
//        CGFloat deltaX = dX * factor;
//        CGFloat deltaY = dY * factor;
//        CGFloat deltaWidth = (self.endLineWidth - self.startLineWidth) * factor;
//        
//        for (int i = 0; i < dotCount + 1; i++) {
//            if (i == 0) {
//                self.fromPoint = self.startPoint;
//            }
//            if (i == dotCount + 1) {
//                self.toPoint = self.endPoint;
//            }
//            self.toPoint = CGPointMake(self.fromPoint.x + deltaX, self.fromPoint.y + deltaY);
//            self.startLineWidth = self.startLineWidth + deltaWidth;
//            CGContextBeginPath(context);
//            CGContextMoveToPoint(context, self.fromPoint.x, self.fromPoint.y);
//            CGContextAddLineToPoint(context, self.toPoint.x,self.toPoint.y);
//            CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
//            CGContextSetLineWidth(context, self.startLineWidth);
//            CGContextSetAlpha(context, 0.5f);
//            CGContextStrokePath(context);
//            self.fromPoint = self.toPoint;
//        }
//        self.startPoint = self.endPoint;
//        self.startLineWidth = self.endLineWidth;
//    }
//    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
//    self.view.layer.contents = (id)self.viewImage.CGImage;
//}

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
}

#pragma mark - TouchesMethods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    self.previousTimestamp = event.timestamp;
    self.endPoint = [[touches anyObject] locationInView:self.view];
    self.startPoint = self.endPoint;
    self.startLineWidth = kMaxLineWidth;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.endPoint = [[touches anyObject] locationInView:self.view];
    CGFloat dx = ABS(self.endPoint.x - self.startPoint.x);
    CGFloat dy = ABS(self.endPoint.y - self.startPoint.y);
    CGFloat distance = 10;
    self.currentSpeed = sqrt(pow(dx, 2) + pow(dy, 2)) / (event.timestamp - self.previousTimestamp) / 1000;
    if (dx > distance || dy > distance) {
        self.endLineWidth = MAX(3, kMaxLineWidth - self.currentSpeed);
        [self drawLine];
        self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
        self.view.layer.contents = (id)self.viewImage.CGImage;
        self.previousTimestamp = event.timestamp;
        self.startPoint = self.endPoint;
        self.startLineWidth = self.endLineWidth;
        self.previousSpeed = self.currentSpeed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!CGPointEqualToPoint(self.endPoint, [[touches anyObject] locationInView:self.view])) {
        [self drawLine];
        self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
        self.view.layer.contents = (id)self.viewImage.CGImage;
    }
//    UIGraphicsEndImageContext();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)array {
    return @[[NSValue valueWithCGPoint:CGPointMake(50, 50)], [NSValue valueWithCGPoint:CGPointMake(50, 100)], [NSValue valueWithCGPoint:CGPointMake(50, 450)], [NSValue valueWithCGPoint:CGPointMake(200, 450)], [NSValue valueWithCGPoint:CGPointMake(200, 50)]];
}

- (NSArray *)speedArray {
    return @[[NSNumber numberWithFloat:20], [NSNumber numberWithFloat:10], [NSNumber numberWithFloat:15], [NSNumber numberWithFloat:10], [NSNumber numberWithFloat:5]];
}

- (void)dealloc {
    UIGraphicsEndImageContext();
}

@end
