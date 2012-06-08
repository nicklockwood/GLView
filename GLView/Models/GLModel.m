//
//  GLModel.h
//
//  GLView Project
//  Version 1.3.2
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

@property (nonatomic, assign) GLfloat *vertices;
@property (nonatomic, assign) GLfloat *texCoords;
@property (nonatomic, assign) GLfloat *normals;
@property (nonatomic, assign) GLushort *elements;
@property (nonatomic, assign) GLuint componentCount;
@property (nonatomic, assign) GLuint vertexCount;
@property (nonatomic, assign) GLuint elementCount;

@end


@implementation GLModel

@synthesize vertices = _vertices;
@synthesize texCoords = _texCoords;
@synthesize normals = _normals;
@synthesize elements = _elements;
@synthesize componentCount = _componentCount;
@synthesize vertexCount = _vertexCount;
@synthesize elementCount = _elementCount;

- (void)dealloc
{
    free(_vertices);
    free(_texCoords);
    free(_normals);
    free(_elements);
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
    self.elementCount = elementAttributes->numElements;
    self.elements = malloc(self.elementCount * sizeof(GLushort));
    switch (elementAttributes->datatype)
    {
        case GL_UNSIGNED_INT:
        {
            GLuint *elements = (GLuint *)(elementAttributes + 1);
            for (GLuint i = 0; i < self.elementCount; i++)
            {
                if (elements[i] >= 0xFFFF)
                {
                    //index is outside the unsigned short range
                    return NO;
                }
                self.elements[i] = elements[i];
            }
            break;
        }
        case GL_UNSIGNED_SHORT:
        {
            memcpy(self.elements, elementAttributes + 1, elementAttributes->byteSize);
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
    self.componentCount = 4;
    self.vertexCount = vertexAttributes->numElements;
    self.vertices = malloc(vertexAttributes->byteSize);
    memcpy(self.vertices, vertexAttributes + 1, vertexAttributes->byteSize);
    
    //copy text coord data
    WWDC2010Attributes *texCoordAttributes = (WWDC2010Attributes *)([data bytes] + toc->byteTexcoordOffset);
    if (texCoordAttributes->datatype != GL_FLOAT)
    {
        //TODO: extend GLModel with support for other data types
        return NO;
    }
    if (texCoordAttributes->byteSize)
    {
        self.texCoords = malloc(texCoordAttributes->byteSize);
        memcpy(self.texCoords, texCoordAttributes + 1, texCoordAttributes->byteSize);
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
        self.normals = malloc(normalAttributes->byteSize);
        memcpy(self.normals, normalAttributes + 1, normalAttributes->byteSize);
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
    self.elementCount = [faceIndexData length] / sizeof(GLushort);
    self.elements = malloc([faceIndexData length]);
    memcpy(self.elements, faceIndexData.bytes, [faceIndexData length]);
    AH_RELEASE(faceIndexData);
    
    //copy vertices
    self.componentCount = 3;
    self.vertexCount = [vertexData length] / (3 * sizeof(GLfloat));
    self.vertices = malloc([vertexData length]);
    memcpy(self.vertices, vertexData.bytes, [vertexData length]);
    AH_RELEASE(vertexData);
    
    //copy texture coords
    if ([textCoordData length])
    {
        self.texCoords = malloc([textCoordData length]);
        memcpy(self.texCoords, textCoordData.bytes, [textCoordData length]);
    }
    AH_RELEASE(textCoordData);
    
    //copy normals
    if ([normalData length])
    {
        self.normals = malloc([normalData length]);
        memcpy(self.normals, normalData.bytes, [normalData length]);
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

+ (GLModel *)modelWithData:(NSData *)data
{
    return AH_AUTORELEASE([[self alloc] initWithData:data]);
}

- (GLModel *)initWithContentsOfFile:(NSString *)path
{
    //convert to absolute path
    path = [path absolutePathWithDefaultExtensions:nil];
        
    //load data
    return [self initWithData:[NSData dataWithContentsOfFile:path]];
}

- (GLModel *)initWithData:(NSData *)data
{
    if (!data)
    {
        //bail early before something bad happens
        AH_RELEASE(self);
        return nil;
    }
    
    if ((self = [self init]))
    {
        //attempt to load model
        if ([self loadAppleWWDC2010Model:data] || [self loadObjModel:data])
        {
            return self;
        }
        else
        {
            NSLog(@"Model data was not in a recognised format");
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
    glVertexPointer(self.componentCount, GL_FLOAT, 0, self.vertices);
    
    if (self.texCoords)
    {
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2, GL_FLOAT, 0, self.texCoords);
    }
    else
    {
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    if (self.normals)
    {
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT, 0, self.normals);
    }
    else
    {
        glDisableClientState(GL_NORMAL_ARRAY);
    }
    
    glDrawElements(GL_TRIANGLES, self.elementCount, GL_UNSIGNED_SHORT, self.elements);
    
    glDisable(GL_DEPTH_TEST);
}

@end
