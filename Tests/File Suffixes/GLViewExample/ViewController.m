//
//  ViewController.m
//  FileSuffixesTest
//
//  Created by Nick Lockwood on 08/06/2012.
//
//

#import "ViewController.h"


@implementation ViewController

@synthesize imageView1;
@synthesize imageView2;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView1.image = [GLImage imageNamed:@"image1"];
    self.imageView2.image = [GLImage imageNamed:@"image2"];
}

@end
