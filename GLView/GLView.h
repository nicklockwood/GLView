//
//  GLView.h
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLView : UIView

- (void)bindFramebuffer;
- (BOOL)presentFramebuffer;

@end
