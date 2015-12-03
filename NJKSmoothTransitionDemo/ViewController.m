//
//  ViewController.m
//  NJKSmoothTransitionDemo
//
//  Created by JiakaiNong on 15/12/2.
//  Copyright © 2015年 poco. All rights reserved.
//

#import "ViewController.h"

@interface NJKDrawingNode ()<NSCopying>

@property (assign, nonatomic) CGPoint point;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat speed;
@property (assign, nonatomic) NSTimeInterval timestamp;

@end

@implementation NJKDrawingNode

- (id)copyWithZone:(nullable NSZone *)zone {
    NJKDrawingNode *node = [[[self class] alloc] init];
    node.point = self.point;
    node.lineWidth = self.lineWidth;
    node.speed = self.speed;
    node.timestamp = self.timestamp;
    return node;
}

@end

@interface ViewController ()

@property (strong, nonatomic) UIImage *viewImage;
@property (strong, nonatomic) NJKDrawingNode *startNode;
@property (strong, nonatomic) NJKDrawingNode *endNode;

@end

@implementation ViewController

static CGFloat kMaxLineWidth = 10;
static CGFloat kMinLineWidth = 3;
static CGFloat kSamplingDistance = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startNode = [[NJKDrawingNode alloc]init];
    self.endNode = [[NJKDrawingNode alloc]init];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
}

- (void)drawLine {
    CGFloat dX = (self.endNode.point.x - self.startNode.point.x);
    CGFloat dY = (self.endNode.point.y - self.startNode.point.y);
    CGFloat distance = sqrt(pow(dX, 2) + pow(dY, 2));
    NSInteger dotCount = distance / (MIN(self.startNode.lineWidth, self.endNode.lineWidth));
    
    CGFloat factor = 1 / ((CGFloat)dotCount + 1);
    CGFloat deltaX = dX * factor;
    CGFloat deltaY = dY * factor;
    CGFloat deltaWidth = (self.endNode.lineWidth - self.startNode.lineWidth) * factor;
    CGFloat lineWidth = self.startNode.lineWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(self.endNode.point.x - self.endNode.lineWidth / 2, self.endNode.point.y - self.endNode.lineWidth / 2, self.endNode.lineWidth, self.endNode.lineWidth));
    
    CGPoint fromPoint = CGPointZero;
    CGPoint toPoint = CGPointZero;
    
    for (int i = 0; i < dotCount + 1; i++) {
        if (i == 0) {
            fromPoint = self.startNode.point;
        }
        if (i == dotCount + 1) {
            toPoint = self.endNode.point;
        }
        toPoint = CGPointMake(fromPoint.x + deltaX, fromPoint.y + deltaY);
        lineWidth += deltaWidth;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetAlpha(context, 0.5f);
        CGContextStrokePath(context);
        fromPoint = toPoint;
    }
    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
    self.view.layer.contents = (id)self.viewImage.CGImage;
}

#pragma mark - TouchesMethods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.endNode.point = [[touches anyObject] locationInView:self.view];
    self.endNode.lineWidth = kMaxLineWidth;
    self.endNode.timestamp = event.timestamp;
    self.startNode = [self.endNode copy];
    [self drawLine];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.endNode.point = [[touches anyObject] locationInView:self.view];
    CGFloat dx = ABS(self.endNode.point.x - self.startNode.point.x);
    CGFloat dy = ABS(self.endNode.point.y - self.startNode.point.y);
    self.endNode.timestamp = event.timestamp;
    self.endNode.speed = sqrt(pow(dx, 2) + pow(dy, 2)) / (self.endNode.timestamp - self.startNode.timestamp) / 1000;
    if (dx > kSamplingDistance || dy > kSamplingDistance) {
        self.endNode.lineWidth = MAX(kMinLineWidth, kMaxLineWidth - self.endNode.speed);
        [self drawLine];
        self.startNode = [self.endNode copy];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!CGPointEqualToPoint(self.endNode.point, [[touches anyObject] locationInView:self.view])) {
        self.endNode.point = [[touches anyObject] locationInView:self.view];
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
