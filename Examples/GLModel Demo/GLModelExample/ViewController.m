//
//  ViewController.m
//  GLModelExample
//
//  Created by Nick Lockwood on 20/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. 
//

#import "ViewController.h"


@implementation ViewController

- (void)setModel:(NSInteger)index
{
    switch (index)
    {
        case 0:
        {
            //set title
            self.navBar.topItem.title = @"demon.model";
            
            //set model
            self.modelView.texture = [GLImage imageNamed:@"demon.png"];
            self.modelView.blendColor = nil;
            self.modelView.model = [GLModel modelWithContentsOfFile:@"demon.model"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -2.0);
            transform = CATransform3DScale(transform, 0.01, 0.01, 0.01);
            transform = CATransform3DRotate(transform, (CGFloat)-M_PI_2, 1.0, 0.0, 0.0);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 1:
        {
            //set title
            self.navBar.topItem.title = @"quad";
            
            //set model
            self.modelView.texture = nil;
            self.modelView.blendColor = [UIColor redColor];
            self.modelView.model = [GLModel modelWithContentsOfFile:@"quad.obj"];
            
            //set default transform
            self.modelView.modelTransform = CATransform3DMakeTranslation(0.0, 0.0, -2.0);
            
            break;
        }
        case 2:
        {
            //set title
            self.navBar.topItem.title = @"chair.obj";
            
            //set model
            self.modelView.texture = [GLImage imageNamed:@"chair.tga"];
            self.modelView.blendColor = nil;
            self.modelView.model = [GLModel modelWithContentsOfFile:@"chair.obj"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -2.0);
            transform = CATransform3DScale(transform, 0.01, 0.01, 0.01);
            transform = CATransform3DRotate(transform, 0.2, 1.0, 0.0, 0.0);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 3:
        {
            //set title
            self.navBar.topItem.title = @"diamond.obj";
            
            //set model
            self.modelView.texture = nil;
            self.modelView.blendColor = [UIColor greenColor];
            self.modelView.model = [GLModel modelWithContentsOfFile:@"diamond.obj"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -1.0);
            transform = CATransform3DScale(transform, 0.01, 0.01, 0.01);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI_2, 1.0, 0.0, 0.0);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 4:
        {
            //set title
            self.navBar.topItem.title = @"cube.obj";
            
            //set model
            self.modelView.texture = nil;
            self.modelView.blendColor = [UIColor whiteColor];
            self.modelView.model = [GLModel modelWithContentsOfFile:@"cube.obj"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -1.0);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI_4, 1.0, 1.0, 0.0);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 5:
        {
            //set title
            self.navBar.topItem.title = @"ship.obj";
            
            //set model
            self.modelView.texture = nil;
            self.modelView.blendColor = [UIColor grayColor];
            self.modelView.model = [GLModel modelWithContentsOfFile:@"ship.obj"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0, 0.0, -15.0);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI + 0.4, 0.0, 0.0, 1.0);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI_4, 1.0, 0.0, 0.0);
            transform = CATransform3DRotate(transform, -0.4, 0.0, 1.0, 0.0);
            transform = CATransform3DScale(transform, 3.0, 3.0, 3.0);
            self.modelView.modelTransform = transform;
            
            break;
        }
    }
}

- (void)selectModel
{
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:nil
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Demon", @"Quad", @"Chair", @"Diamond", @"Cube", @"Ship", nil] showInView:self.view];
}

- (void)actionSheet:(__unused UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0)
    {
        [self setModel:buttonIndex];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setModel:0];
}

@end
