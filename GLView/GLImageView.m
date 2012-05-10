//
//  GLImageView.m
//
//  GLView Project
//  Version 1.2
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#glview
//  https://github.com/nicklockwood/GLView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "GLImageView.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor+GL.h"


@interface GLImageView ()

@property (nonatomic, assign) id currentFrame;

@end


@implementation GLImageView

@synthesize image;
@synthesize blendColor;
@synthesize animationImages;
@synthesize animationDuration;
@synthesize animationRepeatCount;
@synthesize currentFrame;


- (GLImageView *)initWithImage:(GLImage *)_image
{
	if ((self = [self initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)]))
	{
		image = AH_RETAIN(_image);
	}
	return self;
}

- (void)setImage:(GLImage *)_image
{
    if (image != _image)
    {
        AH_RELEASE(image);
        image = AH_RETAIN(_image);
        [self setNeedsLayout];
    }
}

- (void)setAnimationImages:(NSArray *)_animationImages
{
	if (animationImages != _animationImages)
	{
		[self stopAnimating];
		AH_RELEASE(animationImages);
		animationImages = [_animationImages copy];
		animationDuration = [animationImages count] / 30.0;
	}
}

#pragma mark Animation

- (void)startAnimating
{
	if (animationImages)
	{
		[super startAnimating];
	}
}

- (void)step:(NSTimeInterval)dt
{
    //end animation?
    if (animationRepeatCount > 0 && self.elapsedTime / animationDuration >= animationRepeatCount)
    {
        self.elapsedTime = animationDuration * animationRepeatCount - 0.001;
        [self stopAnimating];
    }
	
	//calculate frame
	NSInteger numberOfFrames = [animationImages count];
	if (numberOfFrames)
	{
        NSInteger frameIndex = numberOfFrames * (self.elapsedTime / animationDuration);
		id frame = [animationImages objectAtIndex:frameIndex % numberOfFrames];
		if (frame != currentFrame)
		{
			currentFrame = frame;
			if ([currentFrame isKindOfClass:[GLImage class]])
			{
				self.image = currentFrame;
			}
			else if ([currentFrame isKindOfClass:[NSString class]])
			{
				self.image = [GLImage imageWithContentsOfFile:currentFrame];
			}
		}
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return image.size;
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	if (!self.superview)
	{
		[self stopAnimating];
	}
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self bindFramebuffer];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //set blend color
    [blendColor ?: [UIColor whiteColor] bindGLBlendColor];
	
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
    AH_RELEASE(image);
    AH_RELEASE(blendColor);
	AH_RELEASE(animationImages);
    AH_SUPER_DEALLOC;
}

@end
