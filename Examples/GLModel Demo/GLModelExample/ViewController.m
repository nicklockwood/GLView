//
//  ViewController.m
//  GLModelExample
//
//  Created by Nick Lockwood on 20/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. 
//

#import "ViewController.h"


@implementation ViewController

@synthesize navBar;
@synthesize modelView;

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.navBar = nil;
    self.modelView = nil;
}

- (void)setModel:(NSInteger)index
{
    switch (index)
    {
        case 0:
        {
            //set title
            navBar.topItem.title = @"demon.model";
            
            //set model
            modelView.texture = [GLImage imageNamed:@"demon.png"];
            modelView.blendColor = nil;
            modelView.model = [GLModel modelWithContentsOfFile:@"demon.model"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);
            transform = CATransform3DScale(transform, 0.01f, 0.01f, 0.01f);
            transform = CATransform3DRotate(transform, -M_PI_2, 1.0f, 0.0f, 0.0f);
            modelView.transform = transform;
            
            break;
        }
        case 1:
        {
            //set title
            navBar.topItem.title = @"quad";
            
            //set model
            modelView.texture = nil;
            modelView.blendColor = [UIColor redColor];
            modelView.model = [GLModel modelWithContentsOfFile:@"quad.obj"];
            
            //set default transform
            modelView.transform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);
            
            break;
        }
        case 2:
        {
            //set title
            navBar.topItem.title = @"chair.obj";
            
            //set model
            modelView.texture = [GLImage imageNamed:@"chair.tga"];
            modelView.blendColor = nil;
            modelView.model = [GLModel modelWithContentsOfFile:@"chair.obj"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);
            transform = CATransform3DScale(transform, 0.01f, 0.01f, 0.01f);
            transform = CATransform3DRotate(transform, 0.2f, 1.0f, 0.0f, 0.0f);
            modelView.transform = transform;
            
            break;
        }
        case 3:
        {
            //set title
            navBar.topItem.title = @"diamond.obj";
            
            //set model
            modelView.texture = nil;
            modelView.blendColor = [UIColor greenColor];
            modelView.model = [GLModel modelWithContentsOfFile:@"diamond.obj"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -1.0f);
            transform = CATransform3DScale(transform, 0.01f, 0.01f, 0.01f);
            transform = CATransform3DRotate(transform, M_PI_2, 1.0f, 0.0f, 0.0f);
            modelView.transform = transform;
            
            break;
        }
        case 4:
        {
            //set title
            navBar.topItem.title = @"cube.obj";
            
            //set model
            modelView.texture = nil;
            modelView.blendColor = nil;
            modelView.model = [GLModel modelWithContentsOfFile:@"cube.obj"];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -1.0f);
            transform = CATransform3DRotate(transform, M_PI_4, 1.0f, 1.0f, 0.0f);
            modelView.transform = transform;
            
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
                        otherButtonTitles:@"Demon", @"Quad", @"Chair", @"Diamond", @"Cube", nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0)
    {
        [self setModel:buttonIndex];
    }
}

- (void)viewDidLoad
{
    [self setModel:0];
}

@end
