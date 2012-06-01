//
//  GLViewDrawingExampleController.m
//  GLImageDemo
//
//  Created by Nick Lockwood on 01/06/2012.
//
//

#import "GLViewDrawingExampleController.h"


@implementation GLViewDrawingExampleController

@synthesize drawingView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GLImage *image = [GLImage imageWithSize:self.drawingView.bounds.size
                                      scale:[UIScreen mainScreen].scale
                               drawingBlock:^(CGContextRef context)
    {
        //draw red line
        [[UIColor redColor] setStroke];
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0.0f, 0.0f);
        CGContextAddLineToPoint(context, self.drawingView.bounds.size.width, self.drawingView.bounds.size.height);
        CGContextStrokePath(context);
        
        //draw blue ellipse
        [[UIColor blueColor] setFill];
        CGContextFillEllipseInRect(context, CGRectMake(50.0f, 50.0f, self.drawingView.bounds.size.width - 100.0f, self.drawingView.bounds.size.height - 100.0f));
    }];
    
    self.drawingView.image = image;
}

@end
