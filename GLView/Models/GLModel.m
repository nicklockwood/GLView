//
//  GLModel.h
//
//  GLView Project
//  Version 1.2.2
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

#import "GLModel.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


typedef struct
{
    char fileIdentifier[30];
    unsigned int majorVersion;
    unsigned int minorVersion;
}
WWDC2010Header;

typedef struct
{
    unsigned int attribHeaderSize;
    unsigned int byteElementOffset;
    unsigned int bytePositionOffset;
    unsigned int byteTexcoordOffset;
    unsigned int byteNormalOffset;
}
WWDC2010TOC;

typedef struct
{
    unsigned int byteSize;
    GLenum datatype;
    GLenum primType;
    unsigned int sizePerElement;
    unsigned int numElements;
}
WWDC2010Attributes;


@interface GLModel ()

@property (assign, nonatomic) GLfloat *vertices;
@property (assign, nonatomic) GLfloat *texCoords;
@property (assign, nonatomic) GLfloat *normals;
@property (assign, nonatomic) GLushort *elements;
@property (assign, nonatomic) GLuint componentCount;
@property (assign, nonatomic) GLuint vertexCount;
@property (assign, nonatomic) GLuint elementCount;

@end


@implementation GLModel

@synthesize vertices;
@synthesize texCoords;
@synthesize normals;
@synthesize elements;
@synthesize componentCount;
@synthesize vertexCount;
@synthesize elementCount;

- (void)dealloc
{
    free(vertices);
    free(texCoords);
    free(normals);
    free(elements);
    AH_SUPER_DEALLOC;
}

#pragma mark Private

- (BOOL)loadAppleWWDC2010Model:(NSData *)data
{
    if ([data length] < sizeof(WWDC2010Header) + sizeof(WWDC2010TOC))
    {
        //can't be correct file type
        return NO;  
    }
    
    //check header
    WWDC2010Header *header = (WWDC2010Header *)[data bytes];
    if(strncmp(header->fileIdentifier, "AppleOpenGLDemoModelWWDC2010", sizeof(header->fileIdentifier)))
    {
        return NO;
    }
    if(header->majorVersion != 0 && header->minorVersion != 1)
    {
        return NO;
    }
    
    //load table of contents
    WWDC2010TOC *toc = (WWDC2010TOC *)([data bytes] + sizeof(WWDC2010Header));
    if(toc->attribHeaderSize > sizeof(WWDC2010Attributes))
    {
        return NO;
    }
    
    //copy elements
    WWDC2010Attributes *elementAttributes = (WWDC2010Attributes *)([data bytes] + toc->byteElementOffset);
    if (elementAttributes->primType != GL_TRIANGLES)
    {
        //TODO: extend GLModel with support for other primitive types
        return NO;
    }
    elementCount = elementAttributes->numElements;
    elements = malloc(elementCount * sizeof(GLushort));
    switch (elementAttributes->datatype)
    {
        case GL_UNSIGNED_INT:
        {
            GLuint *_elements = (GLuint *)(elementAttributes + 1);
            for (GLuint i = 0; i < elementCount; i++)
            {
                if (_elements[i] >= 0xFFFF)
                {
                    //index is outside the unsigned short range
                    return NO;
                }
                elements[i] = _elements[i];
            }
            break;
        }
        case GL_UNSIGNED_SHORT:
        {
            memcpy(elements, elementAttributes + 1, elementAttributes->byteSize);
            break;
        }
        default:
        {
            return NO;
        }
    }
    
    //copy vertex data
    WWDC2010Attributes *vertexAttributes = (WWDC2010Attributes *)([data bytes] + toc->bytePositionOffset);
    if (vertexAttributes->datatype != GL_FLOAT)
    {
        //TODO: extend GLModel with support for other data types
        return NO;
    }
    componentCount = 4;
    vertexCount = vertexAttributes->numElements;
    vertices = malloc(vertexAttributes->byteSize);
    memcpy(vertices, vertexAttributes + 1, vertexAttributes->byteSize);
    
    //copy text coord data
    WWDC2010Attributes *texCoordAttributes = (WWDC2010Attributes *)([data bytes] + toc->byteTexcoordOffset);
    if (texCoordAttributes->datatype != GL_FLOAT)
    {
        //TODO: extend GLModel with support for other data types
        return NO;
    }
    if (texCoordAttributes->byteSize)
    {
        texCoords = malloc(texCoordAttributes->byteSize);
        memcpy(texCoords, texCoordAttributes + 1, texCoordAttributes->byteSize);
    }
    
    //copy normal data
    WWDC2010Attributes *normalAttributes = (WWDC2010Attributes *)([data bytes] + toc->byteNormalOffset);
    if (normalAttributes->datatype != GL_FLOAT)
    {
        //TODO: extend GLModel with support for other data types
        return NO;
    }
    if (normalAttributes->byteSize)
    {
        normals = malloc(normalAttributes->byteSize);
        memcpy(normals, normalAttributes + 1, normalAttributes->byteSize);
    }
    
    //success
    return YES;
}

- (BOOL)loadObjModel:(NSData *)data
{
    //convert to string
    NSString *string = [[NSString alloc] initWithBytesNoCopy:(void *)data.bytes length:data.length encoding:NSASCIIStringEncoding freeWhenDone:NO];
    
    //set up storage
    NSMutableData *tempVertexData = [[NSMutableData alloc] init];
    NSMutableData *vertexData = [[NSMutableData alloc] init];
    NSMutableData *tempTextCoordData = [[NSMutableData alloc] init];
    NSMutableData *textCoordData = [[NSMutableData alloc] init];
    NSMutableData *tempNormalData = [[NSMutableData alloc] init];
    NSMutableData *normalData = [[NSMutableData alloc] init];
    NSMutableData *faceIndexData = [[NSMutableData alloc] init];
    
    //utility collections
    NSInteger uniqueIndexStrings = 0;
    NSMutableDictionary *indexStrings = [[NSMutableDictionary alloc] init];
    
    //scan through lines
    NSString *line = nil;
    NSScanner *lineScanner = [NSScanner scannerWithString:string];
    do
    {
        //get line
        [lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
        NSScanner *scanner = [NSScanner scannerWithString:line];
        
        //get line type
        NSString *type = nil;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&type];
        
        if ([type isEqualToString:@"v"])
        {
            //vertex
            GLfloat coords[3];
            [scanner scanFloat:&coords[0]];
            [scanner scanFloat:&coords[1]];
            [scanner scanFloat:&coords[2]];
            [tempVertexData appendBytes:coords length:sizeof(coords)];
        }
        else if ([type isEqualToString:@"vt"])
        {
            //texture coordinate
            GLfloat coords[2];
            [scanner scanFloat:&coords[0]];
            [scanner scanFloat:&coords[1]];
            [tempTextCoordData appendBytes:coords length:sizeof(coords)];
        }
        else if ([type isEqualToString:@"vn"])
        {
            //normal
            GLfloat coords[3];
            [scanner scanFloat:&coords[0]];
            [scanner scanFloat:&coords[1]];
            [scanner scanFloat:&coords[2]];
            [tempNormalData appendBytes:coords length:sizeof(coords)];
        }
        else if ([type isEqualToString:@"f"])
        {
            //face
            int count = 0;
            NSString *indexString = nil;
            while (![scanner isAtEnd])
            {
                count ++;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&indexString];
                
                NSArray *parts = [indexString componentsSeparatedByString:@"/"];
                
                GLushort fIndex = uniqueIndexStrings;
                NSNumber *index = [indexStrings objectForKey:indexStrings];
                if (index == nil)
                {
                    uniqueIndexStrings ++;
                    [indexStrings setObject:[NSNumber numberWithShort:fIndex] forKey:indexString];
                    
                    GLushort vIndex = [[parts objectAtIndex:0] intValue];
                    [vertexData appendBytes:tempVertexData.bytes + (vIndex - 1) * sizeof(GLfloat) * 3 length:sizeof(GLfloat) * 3];

                    if ([parts count] > 1)
                    {
                        GLushort tIndex = [[parts objectAtIndex:1] intValue];
                        if (tIndex) [textCoordData appendBytes:tempTextCoordData.bytes + (tIndex - 1) * sizeof(GLfloat) * 2 length:sizeof(GLfloat) * 2];
                    }
                    
                    if ([parts count] > 2)
                    {
                        GLushort nIndex = [[parts objectAtIndex:2] intValue];
                        if (nIndex) [normalData appendBytes:tempNormalData.bytes + (nIndex - 1) * sizeof(GLfloat) * 3 length:sizeof(GLfloat) * 3];
                    }
                }
                else
                {
                    fIndex = [index shortValue];
                }
                
                if (count > 3)
                {
                    //face has more than 3 sides
                    //so insert extra triangle coords
                    [faceIndexData appendBytes:faceIndexData.bytes + faceIndexData.length - sizeof(GLushort) * 3 length:sizeof(GLushort)];
                    [faceIndexData appendBytes:faceIndexData.bytes + faceIndexData.length - sizeof(GLushort) * 2 length:sizeof(GLushort)];
                }
                
                [faceIndexData appendBytes:&fIndex length:sizeof(GLushort)];
            }
            
        }
        //TODO: more
    }
    while (![lineScanner isAtEnd]);
    AH_RELEASE(string);
    
    //release temporary storage
    AH_RELEASE(tempVertexData);
    AH_RELEASE(tempTextCoordData);
    AH_RELEASE(tempNormalData);
    AH_RELEASE(indexStrings);
    
    //copy elements
    elementCount = [faceIndexData length] / sizeof(GLushort);
    elements = malloc([faceIndexData length]);
    memcpy(elements, faceIndexData.bytes, [faceIndexData length]);
    AH_RELEASE(faceIndexData);
    
    //copy vertices
    componentCount = 3;
    vertexCount = [vertexData length] / (3 * sizeof(GLfloat));
    vertices = malloc([vertexData length]);
    memcpy(vertices, vertexData.bytes, [vertexData length]);
    AH_RELEASE(vertexData);
    
    //copy texture coords
    if ([textCoordData length])
    {
        texCoords = malloc([textCoordData length]);
        memcpy(texCoords, textCoordData.bytes, [textCoordData length]);
    }
    AH_RELEASE(textCoordData);
    
    //copy normals
    if ([normalData length])
    {
        normals = malloc([normalData length]);
        memcpy(normals, normalData.bytes, [normalData length]);
    }
    AH_RELEASE(normalData);
    
    //success
    return YES;
}

#pragma mark Public

+ (GLModel *)modelWithContentsOfFile:(NSString *)path
{
    return AH_AUTORELEASE([[self alloc] initWithContentsOfFile:path]);
}

- (GLModel *)initWithContentsOfFile:(NSString *)path
{
    if ((self = [self init]))
    {
        //convert to absolute path
        if (![path isAbsolutePath])
        {
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
        }
        
        //load data
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        if (!data)
        {
            //bail early before something bad happens
            AH_RELEASE(self);
            return nil;
        }
        
        NSString *extension = [[path pathExtension] lowercaseString];
        if (([extension isEqualToString:@"model"] && [self loadAppleWWDC2010Model:data]) ||
            ([extension isEqualToString:@"obj"] && [self loadObjModel:data]))
        {
            AH_RELEASE(data);
            return self;
        }
        else
        {
            NSLog(@"Model data was not in a recognised format");
            AH_RELEASE(data);
            AH_RELEASE(self);
            return nil;
        }
    }
    return self;
}

- (void)draw
{
    glEnable(GL_DEPTH_TEST);

    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(componentCount, GL_FLOAT, 0, vertices);
    
    if (texCoords)
    {
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    }
    else
    {
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    if (normals)
    {
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT, 0, normals);
    }
    else
    {
        glDisableClientState(GL_NORMAL_ARRAY);
    }
    
    glDrawElements(GL_TRIANGLES, elementCount, GL_UNSIGNED_SHORT, elements);
    
    glDisable(GL_DEPTH_TEST);
}

@end
