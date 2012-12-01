//
//  GLViewImageMapController.m
//  GLImageDemo
//
//  Created by Nick Lockwood on 05/06/2012.
//
//

#import "GLViewImageMapController.h"
#import "GLImageMap.h"
#import "GLImageView.h"


@interface GLViewImageMapController ()

@property (nonatomic, strong) GLImageMap *imageMap;

@end


@implementation GLViewImageMapController

@synthesize imageMap = _imageMap;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageMap = [GLImageMap imageMapWithContentsOfFile:@"lostgarden.plist"];
    self.tableView.rowHeight = 80.0f;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.imageMap imageCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get cell
    NSString *const CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ImageMapTableCell"
                                              owner:nil
                                            options:nil] lastObject];
    }
    
    //set image
    NSString *name = [self.imageMap imageNameAtIndex:indexPath.row];
    ((GLImageView *)[cell viewWithTag:1]).image = [self.imageMap imageNamed:name];
    ((UILabel *)[cell viewWithTag:2]).text = name;
    
    return cell;
}


@end
