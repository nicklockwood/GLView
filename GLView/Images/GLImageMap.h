//
//  GLImageMap.h
//
//  GLView Project
//  Version 1.6.1
//
//  Created by Nick Lockwood on 04/06/2012.
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


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"


#import "GLImage.h"
#import "GLUtils.h"


@interface GLImageMap : NSObject <NSFastEnumeration>

+ (instancetype)imageMapWithContentsOfFile:(NSString *)nameOrPath;
+ (instancetype)imageMapWithImage:(GLImage *)image data:(NSData *)data;

- (instancetype)initWithContentsOfFile:(NSString *)nameOrPath;
- (instancetype)initWithImage:(GLImage *)image data:(NSData *)data;

- (NSUInteger)imageCount;
- (NSString *)imageNameAtIndex:(NSUInteger)index;
- (GLImage *)imageAtIndex:(NSUInteger)index;
- (GLImage *)imageNamed:(NSString *)name;

- (GLImage *)objectAtIndexedSubscript:(NSUInteger)index;
- (GLImage *)objectForKeyedSubscript:(NSString *)name;

@end


#pragma GCC diagnostic pop
