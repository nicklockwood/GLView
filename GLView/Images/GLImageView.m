//
//  GLImageView.m
//
//  GLView Project
//  Version 1.5.1
//
//  Created by Nick Lockwood on 10/07/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
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


@interface GLImageView ()

@property (nonatomic, unsafe_unretained) id currentFrame;

@end


@implementation GLImageView

- (void)setUp
{
	[super setUp];
    
    _imageTransform = CATransform3DIdentity;
}

- (GLImageView *)initWithImage:(GLImage *)image
{
	if ((self = [self initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)]))
	{
		self.image = image;
	}
	return self;
}

- (void)setImage:(GLImage *)image
{
    if (_image != image)
    {
        _image = image;
        [self setNeedsDisplay];
    }
}

- (void)setAnimationImages:(NSArray *)animationImages
{
	if (_animationImages != animationImages)
	{
		[self stopAnimating];
		_animationImages = [animationImages copy];
        NSInteger count = [animationImages count];
		self.animationDuration = count? count / 30.0: 0.0;
        self.currentFrame = nil;
	}
}

- (void)setImageTransform:(CATransform3D)imageTransform
{
    _imageTransform = imageTransform;
    [self setNeedsDisplay];
}


#pragma mark Animation

- (BOOL)shouldStopAnimating
{
    return (self.animationRepeatCount > 0 && self.elapsedTime / self.animationDuration >= self.animationRepeatCount);
}

- (void)step:(NSTimeInterval)dt
{
    //end of animation?
    if ([self shouldStopAnimating])
    {
        self.elapsedTime = self.animationDuration * self.animationRepeatCount - 0.001;
    }
	
	//calculate frame
	NSInteger numberOfFrames = [self.animationImages count];
	if (numberOfFrames)
	{
        NSInteger frameIndex = numberOfFrames * (self.elapsedTime / self.animationDuration);
		id frame = (self.animationImages)[frameIndex % numberOfFrames];
		if (frame != self.currentFrame)
		{
			self.currentFrame = frame;
			if ([frame isKindOfClass:[GLImage class]])
			{
				self.image = frame;
			}
			else if ([frame isKindOfClass:[NSString class]])
			{
				self.image = [GLImage imageWithContentsOfFile:frame];
			}
		}
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return self.image.size;
}

- (void)drawRect:(CGRect)rect
{
    //transform
    glLoadMatrixf((GLfloat *)&_imageTransform);
    
    //draw
    [self.blendColor ?: [UIColor whiteColor] bindGLColor];
	switch (self.contentMode)
	{
		case UIViewContentModeCenter:
		{
			rect = CGRectMake(-self.image.size.width / 2.0f, -self.image.size.height / 2.0f,
							  self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeTopLeft:
		{
			rect = CGRectMake(-self.bounds.size.width / 2.0f, -self.bounds.size.height / 2.0f, 
                              self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeTop:
		{
			rect = CGRectMake(-self.image.size.width / 2.0f, -self.bounds.size.height / 2.0f,
							  self.image.size.width, self.image.size.height);
			break;
		}
        case UIViewContentModeTopRight:
		{
			rect = CGRectMake(self.bounds.size.width / 2.0f - self.image.size.width,
                              -self.bounds.size.height / 2.0f,
							  self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeRight:
		{
			rect = CGRectMake(self.bounds.size.width / 2.0f - self.image.size.width,
							  -self.image.size.height / 2.0f,
							  self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeBottomRight:
		{
			rect = CGRectMake(self.bounds.size.width / 2.0f - self.image.size.width,
							  self.bounds.size.height / 2.0f - self.image.size.height,
							  self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeBottom:
		{
			rect = CGRectMake(-self.image.size.width / 2.0f,
							  self.bounds.size.height / 2.0f - self.image.size.height,
							  self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeBottomLeft:
		{
			rect = CGRectMake(-self.bounds.size.width / 2.0f,
                              self.bounds.size.height / 2.0f - self.image.size.height,
							  self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeLeft:
		{
			rect = CGRectMake(-self.bounds.size.width / 2.0f, -self.image.size.height / 2.0f,
							  self.image.size.width, self.image.size.height);
			break;
		}
		case UIViewContentModeScaleAspectFill:
		{
			CGFloat aspect1 = self.image.size.width / self.image.size.height;
			CGFloat aspect2 = self.bounds.size.width / self.bounds.size.height;
			if (aspect1 < aspect2)
			{
				rect = CGRectMake(-self.bounds.size.width / 2.0f, -self.bounds.size.width / aspect1 / 2.0f,
								  self.bounds.size.width, self.bounds.size.width / aspect1);
			}
			else
			{
				rect = CGRectMake(-self.bounds.size.height * aspect1 / 2.0f, -self.bounds.size.height / 2.0f,
                                  self.bounds.size.height * aspect1, self.bounds.size.height);
			}
			break;
		}
		case UIViewContentModeScaleAspectFit:
		{
			CGFloat aspect1 = self.image.size.width / self.image.size.height;
			CGFloat aspect2 = self.bounds.size.width / self.bounds.size.height;
			if (aspect1 > aspect2)
			{
				rect = CGRectMake(-self.bounds.size.width / 2.0f, -self.bounds.size.width / aspect1 / 2.0f,
								  self.bounds.size.width, self.bounds.size.width / aspect1);
			}
			else
			{
				rect = CGRectMake(-self.bounds.size.height * aspect1 / 2.0f, -self.bounds.size.width / 2.0f,
                                  self.bounds.size.height * aspect1, self.bounds.size.height);
			}
			break;
		}
		case UIViewContentModeScaleToFill:
		default:
		{
			rect = CGRectMake(-self.bounds.size.width / 2.0f, -self.bounds.size.height / 2.0f,
                              self.bounds.size.width, self.bounds.size.height);
		}
	}
    [self.image drawInRect:rect];
}

@end
