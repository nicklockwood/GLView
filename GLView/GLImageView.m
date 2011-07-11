//
//  GLImageView.m
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GLImageView.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@implementation GLImageView

@synthesize image;

- (GLImageView *)initWithImage:(GLImage *)_image
{
	if ((self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)]))
	{
		image = [_image retain];
	}
	return self;
}

- (void)setImage:(GLImage *)_image
{
    if (image != _image)
    {
        [image release];
        image = [_image retain];
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self bindFramebuffer];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
	
	CGRect rect;
	switch (self.contentMode)
	{
		case UIViewContentModeCenter:
		{
			rect = CGRectMake((self.bounds.size.width - image.size.width) / 2,
							  (self.bounds.size.height - image.size.height) / 2,
							  image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeTopLeft:
		{
			rect = CGRectMake(0, 0, image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeTop:
		{
			rect = CGRectMake((self.bounds.size.width - image.size.width) / 2,
							  0, image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeRight:
		{
			rect = CGRectMake(self.bounds.size.width - image.size.width,
							  (self.bounds.size.height - image.size.height) / 2,
							  image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeBottomRight:
		{
			rect = CGRectMake(self.bounds.size.width - image.size.width,
							  self.bounds.size.height - image.size.height,
							  image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeBottom:
		{
			rect = CGRectMake((self.bounds.size.width - image.size.width) / 2,
							  self.bounds.size.height - image.size.height,
							  image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeBottomLeft:
		{
			rect = CGRectMake(0, self.bounds.size.height - image.size.height,
							  image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeLeft:
		{
			rect = CGRectMake(0, (self.bounds.size.height - image.size.height) / 2,
							  image.size.width, image.size.height);
			break;
		}
		case UIViewContentModeScaleAspectFill:
		{
			CGFloat aspect1 = image.size.width / image.size.height;
			CGFloat aspect2 = self.bounds.size.width / self.bounds.size.height;
			if (aspect1 < aspect2)
			{
				rect = CGRectMake(0, (self.bounds.size.height - self.bounds.size.width / aspect1) / 2,
								  self.bounds.size.width, self.bounds.size.width / aspect1);
			}
			else
			{
				rect = CGRectMake((self.bounds.size.width - self.bounds.size.height * aspect1) / 2,
								  0, self.bounds.size.height * aspect1, self.bounds.size.height);
			}
			break;
		}
		case UIViewContentModeScaleAspectFit:
		{
			CGFloat aspect1 = image.size.width / image.size.height;
			CGFloat aspect2 = self.bounds.size.width / self.bounds.size.height;
			if (aspect1 > aspect2)
			{
				rect = CGRectMake(0, (self.bounds.size.height - self.bounds.size.width / aspect1) / 2,
								  self.bounds.size.width, self.bounds.size.width / aspect1);
			}
			else
			{
				rect = CGRectMake((self.bounds.size.width - self.bounds.size.height * aspect1) / 2,
								  0, self.bounds.size.height * aspect1, self.bounds.size.height);
			}
			break;
		}
		case UIViewContentModeScaleToFill:
		default:
		{
			rect = self.bounds;
		}
	}
    [image drawInRect:rect];
	
    [self presentFramebuffer];
}

- (void)dealloc
{
    [image release];
    [super dealloc];
}

@end
