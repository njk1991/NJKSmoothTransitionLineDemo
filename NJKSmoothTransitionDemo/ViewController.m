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
//@property (strong, nonatomic) NJKDrawingNode *startNode;
//@property (strong, nonatomic) NJKDrawingNode *endNode;

@property (assign, nonatomic) CGPoint fromPoint;
@property (assign, nonatomic) CGPoint toPoint;

@property (strong, nonatomic) NJKDrawingNode *node1;
@property (strong, nonatomic) NJKDrawingNode *node2;
@property (strong, nonatomic) NJKDrawingNode *node3;
@property (strong, nonatomic) NJKDrawingNode *node4;

@end

@implementation ViewController

static CGFloat kLineFactor = 0.7;
static CGFloat kMaxLineWidth = 8;
static CGFloat kMinLineWidth = 3;
static CGFloat kSamplingDistance = 10;
static CGPoint kInitPoint = {-100,-100};
static NSInteger kMinDotCount = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.node1 = [[NJKDrawingNode alloc]init];
    self.node2 = [[NJKDrawingNode alloc]init];
    self.node3 = [[NJKDrawingNode alloc]init];
    self.node4 = [[NJKDrawingNode alloc]init];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
}

- (void)drawBSpline {
    
    CGFloat dX = (self.node3.point.x - self.node2.point.x);
    CGFloat dY = (self.node3.point.y - self.node2.point.y);
    CGFloat distance = sqrt(pow(dX, 2) + pow(dY, 2));
    NSInteger dotCount = distance / (MIN(self.node2.lineWidth, self.node3.lineWidth));
    CGFloat factor = 1 / ((CGFloat)dotCount + 1);
    CGFloat deltaWidth = (self.node3.lineWidth - self.node2.lineWidth) * factor;
    CGFloat lineWidth = self.node2.lineWidth;

    if (dotCount <= kMinDotCount) {
        dotCount = kMinDotCount;
    }
    
    for(NSInteger i = 0;i != dotCount; ++i) {
        // use the parametric time value 0 to 1 for this curve
        // segment.
        CGFloat t = (CGFloat)i / dotCount;
        // the t value inverted
        CGFloat it = 1.0f - t;
        
        // calculate blending functions for cubic bspline
        CGFloat b0 = it * it * it / 6.0f;
        CGFloat b1 = (3 * t * t * t - 6 * t * t + 4) / 6.0f;
        CGFloat b2 = (-3 * t * t * t + 3 * t * t + 3 * t + 1) / 6.0f;
        CGFloat b3 =  t * t * t / 6.0f;
        
        // calculate the x,y and z of the curve point
        CGFloat x = b0 * self.node1.point.x + b1 * self.node2.point.x + b2 * self.node3.point.x + b3 * self.node4.point.x;
        
        CGFloat y = b0 * self.node1.point.y + b1 * self.node2.point.y + b2 * self.node3.point.y + b3 * self.node4.point.y;
        // specify the point
        
        if (CGPointEqualToPoint(self.fromPoint, kInitPoint)) {
            self.fromPoint = CGPointMake(x, y);
        }
        self.toPoint = CGPointMake(x, y);
        lineWidth += deltaWidth;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, self.fromPoint.x, self.fromPoint.y);
        CGContextAddLineToPoint(context, self.toPoint.x, self.toPoint.y);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        CGContextSetLineWidth(context, lineWidth);
//        CGContextSetAlpha(context, 0.5f);
        CGContextStrokePath(context);
        self.fromPoint = self.toPoint;
    }
    self.viewImage = UIGraphicsGetImageFromCurrentImageContext();
    self.view.layer.contents = (id)self.viewImage.CGImage;
}

#pragma mark - TouchesMethods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NJKDrawingNode *node = [[NJKDrawingNode alloc]init];
    node.point = [[touches anyObject] locationInView:self.view];
    node.lineWidth = kMaxLineWidth;
    node.timestamp = event.timestamp;
    node.speed = 0;
    [self initPoints];
    [self initNodesWithNode:node];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NJKDrawingNode *node = [[NJKDrawingNode alloc]init];
    node.point = [[touches anyObject] locationInView:self.view];
    CGFloat dx = ABS(node.point.x - self.node4.point.x);
    CGFloat dy = ABS(node.point.y - self.node4.point.y);
    node.timestamp = event.timestamp;
    node.speed = sqrt(pow(dx, 2) + pow(dy, 2)) / (node.timestamp - self.node4.timestamp) / 1000;
    if (dx > kSamplingDistance || dy > kSamplingDistance) {
        node.lineWidth = MAX(kMinLineWidth, kMaxLineWidth - self.node4.speed * kLineFactor);
        [self refreshNodesWithNode:node];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NJKDrawingNode *node = [self.node4 copy];
    node.point = [[touches anyObject] locationInView:self.view];
    
    if (!CGPointEqualToPoint(self.node4.point, node.point)) {
        [self refreshNodesWithNode:node];
        [self refreshNodesWithNode:node];
        [self refreshNodesWithNode:node];
    }
    [self refreshNodesWithNode:node];
    [self refreshNodesWithNode:node];
}

- (void)initPoints {
    self.fromPoint = kInitPoint;
    self.toPoint = kInitPoint;
}

- (void)initNodesWithNode:(NJKDrawingNode *)node {
    self.node1 = [node copy];
    self.node2 = [node copy];
    self.node3 = [node copy];
    self.node4 = [node copy];
    [self drawBSpline];
}

- (void)refreshNodesWithNode:(NJKDrawingNode *)node {
    self.node1 = [self.node2 copy];
    self.node2 = [self.node3 copy];
    self.node3 = [self.node4 copy];
    self.node4 = [node copy];
    [self drawBSpline];
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
