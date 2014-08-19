//
//  ViewController.m
//  GLModelExample
//
//  Created by Nick Lockwood on 20/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. 
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.navBar = nil;
    self.modelView = nil;
}

- (void)setModel:(NSInteger)index
{
    [self.modelView.models removeAllObjects];
    [self.modelView.textures removeAllObjects];
    
    switch (index)
    {
        case 0:
        {
            //set title
            self.navBar.topItem.title = @"demon.model";
            
            //set model
            [self.modelView addTexture:[GLImage imageNamed:@"demon.png"]];
            self.modelView.blendColor = nil;
            [self.modelView addModel:[GLModel modelWithContentsOfFile:@"demon.model"]];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);
            transform = CATransform3DScale(transform, 0.01f, 0.01f, 0.01f);
            transform = CATransform3DRotate(transform, (CGFloat)-M_PI_2, 1.0f, 0.0f, 0.0f);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 1:
        {
            //set title
            self.navBar.topItem.title = @"quad";
            
            //set model
            self.modelView.blendColor = [UIColor redColor];
            [self.modelView addModel:[GLModel modelWithContentsOfFile:@"quad.obj"]];
            
            //set default transform
            self.modelView.modelTransform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);
            
            break;
        }
        case 2:
        {
            //set title
            self.navBar.topItem.title = @"chair.obj";
            
            //set model
            [self.modelView addTexture:[GLImage imageNamed:@"chair.tga"]];
            self.modelView.blendColor = nil;
            [self.modelView addModel:[GLModel modelWithContentsOfFile:@"chair.obj"]];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);
            transform = CATransform3DScale(transform, 0.01f, 0.01f, 0.01f);
            transform = CATransform3DRotate(transform, 0.2f, 1.0f, 0.0f, 0.0f);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 3:
        {
            //set title
            self.navBar.topItem.title = @"diamond.obj";
            
            //set model
            self.modelView.blendColor = [UIColor greenColor];
            [self.modelView addModel:[GLModel modelWithContentsOfFile:@"diamond.obj"]];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -1.0f);
            transform = CATransform3DScale(transform, 0.01f, 0.01f, 0.01f);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI_2, 1.0f, 0.0f, 0.0f);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 4:
        {
            //set title
            self.navBar.topItem.title = @"cube.obj";
            
            //set model
            self.modelView.blendColor = [UIColor whiteColor];
            [self.modelView addModel:[GLModel modelWithContentsOfFile:@"cube.obj"]];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -1.0f);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI_4, 1.0f, 1.0f, 0.0f);
            self.modelView.modelTransform = transform;
            
            break;
        }
        case 5:
        {
            //set title
            self.navBar.topItem.title = @"ship.obj";
            
            //set model
            self.modelView.blendColor = [UIColor grayColor];
            [self.modelView addModel:[GLModel modelWithContentsOfFile:@"ship.obj"]];
            
            //set default transform
            CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -15.0f);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI + 0.4f, 0.0f, 0.0f, 1.0f);
            transform = CATransform3DRotate(transform, (CGFloat)M_PI_4, 1.0f, 0.0f, 0.0f);
            transform = CATransform3DRotate(transform, -0.4f, 0.0f, 1.0f, 0.0f);
            transform = CATransform3DScale(transform, 3.0f, 3.0f, 3.0f);
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
