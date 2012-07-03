//
//  GLUtils.h
//
//  GLView Project
//  Version 1.3.4
//
//  Created by Nick Lockwood on 04/06/2012.
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

///Users/nick.lockwood/Dropbox/Open Source (GIT)/GLView/GLView/Images/GLImage.h
//  ARC Helper
//
//  Version 1.3.1
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef AH_RETAIN
#if __has_feature(objc_arc)
#define AH_RETAIN(x) (x)
#define AH_RELEASE(x) (void)(x)
#define AH_AUTORELEASE(x) (x)
#define AH_SUPER_DEALLOC (void)(0)
#define __AH_BRIDGE __bridge
#else
#define __AH_WEAK
#define AH_WEAK assign
#define AH_RETAIN(x) [(x) retain]
#define AH_RELEASE(x) [(x) release]
#define AH_AUTORELEASE(x) [(x) autorelease]
#define AH_SUPER_DEALLOC [super dealloc]
#define __AH_BRIDGE
#endif
#endif

//  ARC Helper ends


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


void CGRectGetGLCoords(CGRect rect, GLfloat *coords);


@interface NSString (GL)

- (NSString *)stringByAppendingScaleSuffix;
- (NSString *)stringByDeletingScaleSuffix;
- (NSString *)scaleSuffix;
- (CGFloat)scale;

- (NSString *)stringByAppendingInterfaceIdiomSuffix;
- (NSString *)stringByDeletingInterfaceIdiomSuffix;
- (NSString *)interfaceIdiomSuffix;
- (UIUserInterfaceIdiom)interfaceIdiom;

- (NSString *)stringByAppendingHDSuffix;
- (NSString *)stringByDeletingHDSuffix;
- (NSString *)HDSuffix;
- (BOOL)isHD;

- (NSString *)absolutePathWithDefaultExtensions:(NSString *)firstExtension, ... NS_REQUIRES_NIL_TERMINATION;

@end


@interface UIColor (GL)

- (void)getGLComponents:(GLfloat *)rgba;
- (void)bindGLClearColor;
- (void)bindGLBlendColor;
- (void)bindGLColor;

@end