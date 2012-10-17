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
    
    //test with no file extension (should default to png)
    self.imageView1.image = [GLImage imageNamed:@"image1"];
    
    //test with .gz extension (not actually gzipped, just checking path logic)
    self.imageView2.image = [GLImage imageNamed:@"image2.png.gz"];
}

@end
