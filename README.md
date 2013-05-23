Purpose
--------------

GLView is a collection of classes designed to make it as easy as possible to get up and running with OpenGL functionality within an iOS app.

The GLImage and GLImageView classes make it possible to load and display PVR formatted images and video clips in your app without needing to know any OpenGL whatsoever. See more about PVR images and video below.

The GLModel and GLModelView classes allow you to load a 3D model using the popular WaveFront .obj format and display it in a view, again without needing to know anything about OpenGL.

The GLView library is modular. If you don't want to render 3D models you can omit the Models classes and the rest of the library will still work. If you aren't interested in loading and displaying images and just want a basic OpenGL context set up for you, you can omit the Images and Models classes.


Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 6.1 (Xcode 4.6.2, Apple LLVM compiler 4.2)
* Earliest supported deployment target - iOS 5.0
* Earliest compatible deployment target - iOS 4.3

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

As of version 1.5, GLView requires ARC. If you wish to use GLView in a non-ARC project, just add the -fobjc-arc compiler flag to all of the GLView class files. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click each of the GLView-related .m files in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in GLUtils.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including all of the GLView files) are checked.


Installation
---------------

To use GLView, just drag the class files into your project and add the QuartzCore and OpenGLES frameworks. If you are using the optional GZIP library then you will also need to add the libz.dylib.


Classes
---------------

The GLView library currently includes the following classes:

- GLUtils - this is a collection of useful class extensions and global methods that are used by the GLView library. 

- GLView - this is a general-purpose UIView subclass for displaying OpenGL graphics on screen. It doesn't display anything by default, but if you are familiar with OpenGL you can use it for raw OpenGL drawing.

- GLImage - this is a class for loading image files as OpenGL textures. It supports all the same image formats as UIImage, as well as a number of PVR image formats.

- GLImageMap - this is a class for loading image maps, also known as image atlases or spritemaps.

- GLImageView - this is a subclass of GLView, specifically designed for displaying GLImages. It behaves in a similar way to UIImageView and mostly mirrors its interface.

- GLModel - this is a class for loading 3D mesh geometry for rendering in a GLView. It currently supports only Wavefront .obj files and the bespoke "WWDC2010" model format used in the Apple GLEssentials sample code, but will support additional formats in future.

- GLModelView - this is a subclass of GLView, specifically designed for displaying GLModels as simply and easily as possible.

- GLLight - this class represents a light source and is used for illuminating GLModel objects in the GLModelView.


Global methods
------------------

    void CGRectGetGLCoords(CGRect rect, GLfloat *coords);

This method is used by the GLView library for converting GLRects into OpenGL vertices. It receives a pointer to an array of 8 GLfloats, and it populates the array with the coordinates for the 4 corners of the rect.


UIColor extensions 
---------------------

These methods extend UIColor to make it easier to integrate with OpenGL code.

    - (void)getGLComponents:(GLfloat *)rgba;
    
Pass in a pointer to a C array of four GLfloats and this method will populate them with the red, green, blue and alpha components of the UIColor. Works with monochromatic and RGB UIColors, but will fail if the color contains a pattern image, or some other unsupported color format.
    
    - (void)bindGLClearColor;

Binds the UIColor as the current OpenGL clear color.
    
    - (void)bindGLBlendColor;
    
Binds the UIColor as the current OpenGL blend color.

    - (void)bindGLColor;
    
Binds the UIColor as the current OpenGL color.


GLView properties
----------------

    @property (nonatomic, assign) CGFloat fov;

This is the vertical field of view, in radians. This defaults to zero, which gives an orthographic projection (no perspective) but set it to around Pi/2 (90 degrees) for a perspective projection.

    @property (nonatomic, assign) CGFloat near;

The near clipping plane. This is used by OpenGL to clip geometry that is too close to the camera. In orthographic projection mode, this value can be negative, but in perspective mode the value must be greater than zero.

    @property (nonatomic, assign) CGFloat far;

The far clipping plane. This is used by OpenGL to clip geometry that is too far from the camera. A smaller value for the far plane improves the precision of the z-buffer and reduces rendering artefacts, so try to set this value as low as possible (Note: it must be larger than the near value).

    @property (nonatomic, assign) NSTimeInterval frameInterval;

This property controls the frame rate of the view animation. The default value is 1.0/60.0 (60 frames per second). You may wish to reduce this to 30 fps if your animation becomes choppy.

    @property (nonatomic, assign) NSTimeInterval elapsedTime;

This property is used when animating the view. It indicates the total animation time elapsed since the startAnimating method was first called. It is not reset when stop is called, but you can reset it manually at any time as it is a read/write property.


GLView methods
----------------

GLView has the following methods:

    - (void)setUp
    
Called by `initWithCoder: and `initWithFrame:` to initialise the view. Override this method to do setup code in your own GLView subclasses. Remember to call [super setUp] or the view won't work properly.

    - (void)display;
    
If you are managing drawing yourself using an update loop, you can call this method to call the drawRect: method immediately instead of waiting for the next OS frame update.

    - (void)drawRect:(CGRect)rect;
    
This method (inherited from UIView) is responsible for drawing the view contents. The default implementation does nothing, but you can override this method in a GLView subclass to perform your own OpenGL rendering logic.

	- (void)bindFramebuffer;

This method is used to bind the GLView before attempting any drawing using OpenGL commands. This method is called automatically prior to the `drawRect:` method, so in most cases you won't ever need to call it yourself.

	- (BOOL)presentRenderbuffer;

Call this method to update the view and display the result of any previous drawing commands. This method is called automatically after the `drawRect:` method, so in most cases you won't ever need to call it yourself.

    - (void)startAnimating;
    
Begin animating the view. This will cause the `step:` method to be called repeatedly every 60th second, allowing you to do frame-by-frame animation of your OpenGL geometry.
    
    - (void)stopAnimating;
    
Pauses the animation. The elapsedTime property is not automatically reset so calling `startAnimating` again will resume the animation from the point at which it stopped.
    
    - (BOOL)isAnimating;
    
Returns YES if the view is currently animating and NO if it isn't.

    - (BOOL)shouldStopAnimating;

This method is used to automatically stop the animation when some criterion is met. It returns NO by default, but can be overridden by subclasses of GLView. As an example, GLImageView overrides this method to return YES when the animated image sequence comes to an end.
    
    - (void)step:(NSTimeInterval)dt;

This method is called every 60th of a second while the view is animating. The dt parameter is the time (in seconds) since the last step (this will usually be ~1/60 seconds depending on the complexity of your rendering code and device performance). The default implementation does nothing, but you can override this method to create your own animation logic.

    - (UIImage *)snapshot;
    
This method returns the current contents of the GLView (including any subviews) as a UImage. Note that calling this method will always cause the view contents to be immediately re-rendered by calling the drawRect: method, even if the view has recently been updated. The CALayer renderInContext: method for the layer backing the GLView has also been implemented, allowing you to capture any hierarchy of views that includes GLView instances. 


GLImage properties
-------------------

	@property (nonatomic, readonly) CGSize size;
	
The size of the image, in points. As with UIImage, on a retina display device the actual pixel dimensions may be twice the size, depending on the scale property.
	
	@property (nonatomic, readonly) CGFloat scale;

The image scale. For @2x images on Retina display devices this will have a value of 2.0.

    @property (nonatomic, readonly) GLuint texture;
    
The underlying texture ID used by the GLImage. You can use this to bind the texture in your own drawing code if you do not want to use the `bindTexture` method.

    @property (nonatomic, readonly) CGSize textureSize;
    
The size of the underlying texture. The dimensions of the texture will always be a power of two. For images that have a scale of 1.0 (non-Retina) and have power-of-two dimensions, this will match the size property.

    @property (nonatomic, readonly) CGRect clipRect;

The clipping rectangle used to crop and resize the texture to fit the image rect. This rect is measured in texture pixels, so for images that are not clipped, the clipRect size will match the textureSize.

    @property (nonatomic, readonly) CGRect contentRect;

The content rectangle used to specify the portion of the image which is textured. This rect is measured in image pixels. In most cases the size of this rect will match the image size and the origin will be zero, however if the image content has been trimmed from its original size, the contentRect may be smaller than the bounds specified by the image size.

    @property (nonatomic, readonly) BOOL premultipliedAlpha;

Images that have translucent parts can either use premultiplied or non-premultiplied alpha. iOS typically uses premultiplied alpha when loading images and this is the default for non-PVR images. PVR images generated using Apple's command-line tools do not have premultiplied alpha, so for PVR images it is assumed that the image does not have premultiplied alpha so this property will be NO for PVR images by default, however some tools have the option to generate PVR images with premultiplied alpha, and this is generally recommended to avoid odd black or white halos around opaque parts of the image. There is no way to detect if a PVR image was generated with premultiplied alpha, so if you know that it was, or if the image looks wrong when rendered, you can toggle this property using the `imageWithPremultipliedAlpha:` method. See the Premultiplied Alpha section below for more details.

    @property (nonatomic, readonly) const GLfloat *textureCoords;

The texture coordinates used for rendering the image. These are handy if you need to render the image yourself using OpenGL functions instead of using the `drawAtPoint:` or `drawInRect:` methods. The textureCoords array will always contain exactly 8 GLfloat values.

    @property (nonatomic, readonly) const GLfloat *vertexCoords;

The vertex coordinates used for rendering the image. These are handy if you need to render the image yourself using OpenGL functions instead of using the `drawAtPoint:` or `drawInRect:` methods. The vertexCoords array will always contain exactly 8 GLfloat values.


GLImage methods
------------------

	+ (GLImage *)imageNamed:(NSString *)nameOrPath;
	
This method works more-or-less like the equivalent UIImage method. The image file specified by the nameOrPath paramater will be loaded and returned. The image is also cached so that any subsequent `imageNamed:` calls for the same file will return the exact same copy of the image. In a low memory situation, this cache will be cleared. Retina display images using the @2x naming scheme also behave the same way as for UIImage, as do images that have the ~ipad suffix.

The name can include a file extension. If it doesn't, .png is assumed. The name may also include a full or partial file path, and, unlike UIImage's version, GLImage's `imageNamed:` function can load images outside of the application bundle, such as from the application documents folder. Note however that because these images are cached, it is unwise to load images in this way if they are likely to be replaced or deleted while the app is running, as this may result in unexpected behaviour.

**NOTE:** OpenGL textures are required to have dimensions that are a power of two, e.g. 8x128, 32x64, 128x128, 512x256, etc. As of version 1.2.2, GLImage can load images whose dimensions are not powers of two and it will automatically frame them inside the smallest valid texture size. However, it is still recommended that you try to use images that are powers of two whenever possible, as it avoids wasting video memory.
	
	+ (GLImage *)imageWithContentsOfFile:(NSString *)nameOrPath;
	- (GLImage *)initWithContentsOfFile:(NSString *)nameOrPath;

These methods load a GLImage from a file. The path parameter can be a full or partial path. For partial paths it is assumed that the path is relative to the application resource folder. If the file extension is omitted, it is assumed to be .png. Retina display images using the @2x naming scheme behave the same way as for UIImage, as do images that have the ~ipad suffix. Images loaded in this way are not cached or de-duplicated in any way.
	
	+ (GLImage *)imageWithUIImage:(UIImage *)image;
	- (GLImage *)initWithUIImage:(UIImage *)image;
	
These methods create a GLImage from an existing UIImage. The original scale and orientation of the UIImage are preserved. The result GLIImage format will be a 32-bit uncompressed RGBA texture.
	
    + (GLImage *)imageWithSize:(CGSize)size scale:(CGFloat)scale drawingBlock:(GLImageDrawingBlock)drawingBlock;
    - (GLImage *)initWithSize:(CGSize)size scale:(CGFloat)scale drawingBlock:(GLImageDrawingBlock)drawingBlock;

These methods allow you to create a new GLImage by drawing the contents directly using Core Graphics. The first and second arguments specify the size and scale of the image, and the third argument is a block function that you use to do your drawing. The block takes a single argument which is the CGContextRef for you to draw into. See the "Drawing" tab in the GLImage Demo example app for a demonstration.

    + (GLImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;
    - (GLImage *)initWithData:(NSData *)data scale:(CGFloat)scale;

These methods allow you to create a GLImage from an NSData object. The data content should correspond to an image file in one of the formats supported by `imageWithContentsOfFile:`. The image size and format is derived automatically from the data. The scale parameter can be used to indicate the display resolution that the image is optimised for.

    - (GLImage *)imageWithPremultipliedAlpha:(BOOL)premultipliedAlpha;
    
Images that have translucent parts can either use premultiplied or non-premultiplied alpha. iOS typically uses premultiplied alpha when loading images and this is the default for non-PVR images. PVR images generated using Apple's command-line tools do not have premultiplied alpha, so for PVR images it is assumed that the image does not have premultiplied alpha. Some tools however have the option to generate PVR images with premultiplied alpha, and this is generally recommended to avoid odd black or white halos around opaque parts of the image, but since there is no way to detect this from the file format, these images may render incorrectly when loaded with GLImage. To correct this, use this method with a value of YES to create a version of the image that will render correctly. See the Premultiplied Alpha section below for more details.

    - (GLImage *)imageWithOrientation:(UIImageOrientation)orientation;

If your image is flipped or was rotated to fit into a larger image map, you can change the orientation at which it is displayed by updating the orientation with this method. This method doesn't change the image pixels, it only affects the way in which it is displayed by the `drawAtPoint:` and `drawInRect:` methods.
    
    - (GLImage *)imageWithClipRect:(CGRect)clipRect;
    
This method can be used to set the clipping rect for the image. This is useful if you are loading a PVR texture image where the content is smaller than the image bounds but, due to the PVR format restrictions, the image file has to be a square with power-of-two sides. Note that the clipping rect is measured in texture pixels, not in image coordinates, and does not take into account the scale factor or previous clipping. You can determine the actual texture Size from the textureSize property of the image. **Note:** Adjusting the clipRect will also adjust the image size and contentRect accordingly, however you can override this by calling `imageWithSize:` and/or `imageWithContentRect:` afterwards.

    - (GLImage *)imageWithContentRect:(CGRect)contentRect;
    
This method can be used to set the content rect for the image. This is useful if you want to manipulate the image's anchor point, or add padding around the textured part of the image.

    - (GLImage *)imageWithScale:(CGFloat)scale;
    
This method can be used to set the image scale. Modifying the scale will automatically update the image size and contentRect accordingly, but will not actually change the image pixels. In the unlikely case that you wish to set the scale without modifying the image size, you can override call `imageWithSize:` afterwards to restore the original size.

    - (GLImage *)imageWithSize:(CGSize)size;
    
This method can be used to set the image size. This method does not actually modify the image pixels, it merely changes the default horizontal and vertical scale factor at which the image is drawn when using the `drawAtPoint:` method.

	- (void)bindTexture;
	
This method is used to bind the underlying OpenGL texture of the GLImage prior to using it for OpenGL drawing.
	
	- (void)drawAtPoint:(CGPoint)point;
	
This method will draw the image into the currently bound GLView or OpenGL context at the specified point.
	
	- (void)drawInRect:(CGRect)rect;

This method will draw the image into the currently bound GLView or OpenGL context, stretching it to fit the specified CGRect.


GLImageMap methods
----------------------

The GLImageMap class has the following methods:

    + (GLImageMap *)imageMapWithContentsOfFile:(NSString *)nameOrPath;
    - (GLImageMap *)initWithContentsOfFile:(NSString *)nameOrPath;
    
These methods are used to create a GLImageMap from a file. The parameter can be an absolute or relative file path (relative paths are assumed to be inside the application bundle). If the file extension is omitted it is assumed to be .plist. Currently the only image map file format that is supported is the Cocos2D sprite map format, which can be exported by tools such as Zwoptex or TexturePacker. GLImageMap fully supports trimmed, rotated and aliased images. As with ordinary GLImages, GLImageMap will automatically detect @2x retina files and files with the ~ipad suffix.

    + (GLImageMap *)imageMapWithImage:(GLImage *)image data:(NSData *)data;    
    - (GLImageMap *)initWithImage:(GLImage *)image data:(NSData *)data;
    
These methods are used to create a GLImage from data. The data should represent the contents of an image map file in one of the formats supported by the `imageMapWithContentsOfFile:` method. If the image argument is nil, GLImageMap will attempt to locate the texture file from the filename specified in the data, however if the image file is not located in the root of the application bundle, it may not be able to find it. In this case, you can supply a GLImage to be used as the image map image and the image file specified in the data will be ignored.
    
    - (NSInteger)imageCount;
    
This method returns the number of images in the image map.
    
    - (NSString *)imageNameAtIndex:(NSInteger)index;
    
This method returns the image name at the specified index. Note that image map images are unordered, so do not assume that the image order will match the order of images in the file that was loaded. If you wish to access image map images in a specific order, it is a good idea to name them numerically.
    
    - (GLImage *)imageAtIndex:(NSInteger)index;
    
This method returns the image map image at the specified index. Note that image map images are unordered, so do not assume that the image order will match the order of images in the file that was loaded. If you wish to access image map images in a specific order, it is a good idea to name them numerically.
    
    - (GLImage *)imageNamed:(NSString *)name;
    
This method returns the image map image with the specified name. Depending on the tool used to generate the image map data file, the names may include a file extension. If you do not include a file extension in the image name, png is assumed.


GLImageView properties
-----------------------

The GLImage view has the following properties:

	@property (nonatomic, strong) GLImage *image;

This is used to set and display a GLImage within the view. The standard UIView `contentMode` property is respected when drawing the image, in terms of how it is cropped, stretched and positioned within the view.

    @property (nonatomic, strong) UIColor *blendColor;
    
An (optional) color to blend with the image before it is rendered. This can be used to tint the image, or modify its opacity, etc. Defaults to white.

	@property (nonatomic, copy) NSArray *animationImages;
	
This is used to specify a sequence of images to be played as an animation. The array can contain either GLImages, or filenames. If filenames are supplied then the images will be streamed from disk rather than being loaded in advance. See the Video tab of the GLImage Demo example app for a demonstration of how this can be used to play a large PVR video sequence with smooth 30fps performance and minimal memory consumption. 
	
	@property (nonatomic, assign) NSTimeInterval animationDuration;

The duration over which the animationImages sequence will play. This is measured in seconds and defaults to the number of animation frames divided by 30 (i.e. 30 frames-per-second). This value is automatically set whenever the animationImages array is updated, so remember to set this *after* you set the animationImages property.

	@property (nonatomic, assign) NSInteger animationRepeatCount;

The number of times the animation will repeat. Defaults to zero, which causes the animation to repeat indefinitely until the `stopAnimating` method is called.

    @property (nonatomic, assign) CATransform3D imageTransform;
    
A 3D transform to apply to the image. This can be used to center, scale or rotate the image. This can be useful for implementing pinch to zoom/rotate functionality. It is more efficient to transform the image using this property than to transform the entire view using the view.transform or view.layer.transform properties.


GLImageView methods
-----------------------

	- (GLImageView *)initWithImage:(GLImage *)image;
	
This method creates a GLImageView containing the specified image and sets the view frame to match the image size.

	- (void)startAnimating;
	
Inherited from GLView, this method starts the `animationImages` sequence. Playback always starts from the first frame. Calling play when the animation is already playing will start it again from the beginning.
	
    - (void)stopAnimating;

This method stops the animation sequence. Once stopped, the sequence can not be resumed, only started again from the beginning.

    - (BOOL)isAnimating;

This method returns YES if the `animationImages` sequence is currently playing.


GLModel methods
--------------------

    + (GLModel *)modelNamed:(NSString *)nameOrPath;
    
This method loads the model file specified by the nameOrPath paramater and returns a GLModel. The model is cached so that any subsequent `modelNamed` calls for the same file will return the exact same copy of the model. In a low memory situation, this cache will be cleared.

The name can include a file extension. If it doesn't, .obj is assumed. The name may also include a full or partial file path. Like the GLImage imageNamed: function, modelNamed: can load models outside of the application bundle, such as from the application documents folder. However, because these models are cached, it is unwise to load models in this way if they are likely to be replaced or deleted while the app is running, as this may result in unexpected behaviour.

    + (GLModel *)modelWithContentsOfFile:(NSString *)path;
    - (GLModel *)initWithContentsOfFile:(NSString *)path;
    
These methods load a GLModel from a file. The path parameter can be a full or partial path. For partial paths it is assumed that the path is relative to the application resource folder. The format is inferred from the file extension; Currently only .obj (Wavefront) and .model (Apple's GLEssentials sample code model format) files are accepted. Models loaded in this way are not cached or de-duplicated in any way. Note that is is also possible to use the @2x and ~ipad filename suffixes to specify different models for different devices, which is useful if you wish to provide more detailed models for higher-end devices.

    - (GLModel *)initWithContentsOfFile:(NSString *)path;
    - (GLModel *)initWithData:(NSData *)data;

These methods initialise a model with data. The format of the data should match the contents of one of the supported file formats.

    - (void)draw;

Renders the model in the current GLView.  In practice you may wish to configure the OpenGL state for the model before calling draw, e.g. by setting a texture image to use for the rendering. See the GLModelView `layoutSubviews` method for an example.


GLModelView properties
-----------------------

    @property (nonatomic, strong) GLModel *model;
    
The model that will be rendered by the view.
    
    @property (nonatomic, strong) GLImage *texture;
    
A GLImage that will be used to texture the model. The model must have texture coordinates defined in order for the texture to be applied correctly.
    
    @property (nonatomic, strong) UIColor *blendColor;
    
A color to blend with the model texture. This can be used to tint the model or modify its opacity. If no texture image is specified, the model will be flat-shaded in this color.

    @property (nonatomic, copy) NSArray *lights;
    
An array of GLLight objects used to illuminate the model. By default this array contains a single white light positioned above and to the left of the object. You can set up to eight lights, although increasing the number of lights has a negative impact on performance. Setting an empty array is equivalent to having a single ambient white light.
    
    @property (nonatomic, assign) CATransform3D modelTransform;
    
A 3D transform to apply to the model. This can be used to center, scale or rotate the model to fit the view frame. See the example project for how this can be used.


GLLight properties
---------------------

    @property (nonatomic, strong) UIColor *ambientColor;
    
The ambient light color. This color is used to illuminate the object uniformly. Defaults to black (off).
    
    @property (nonatomic, strong) UIColor *diffuseColor; 
    @property (nonatomic, strong) UIColor *specularColor;
    
The diffuse and specular light colors. These illuminate the object in a directional fashion, eminating from the position specified by the transform. These default to white (full brightness).
    
    @property (nonatomic, assign) CATransform3D transform;

The transform property controls the position of the light. Currently only the position/translation part of the transform is used. Rotation and scale properties are ignored. Use CATransform3DMakeTranslation(x, y, z) to set a suitable value. The default translation is (0, 0, 1), which is typically behind the camera, or between the camera and the scene being viewed.


GLLight methods
---------------------

    - (void)bind:(GLuint)light;

This method binds the GLLight to a particular light in the scene. The light parameter is an OpenGL constant representing the light index, where GL_LIGHT0 is the first available light, and GL_LIGHT7 is typically the last available light.


Image file suffixes
--------------------

iOS has a clever mechanism for managing multiple versions of assets by using file suffixes. The first iPad introduced the ~ipad suffix for specifying ipad-specific versions of files (e.g. foo~ipad.png). The iPhone 4 introduced the @2x suffix for managing double-resolution images for Retina displays (e.g. foo@2x.png). With the 3rd generation iPad you can combine these to have Retina-quality iPad images (e.g. foo@2x~ipad.png).

GLImage supports the @2x and ~ipad suffixes automatically, so if you attempt to load an image called foo.png, GLImage will automatically look for foo@2x.png on a Retina iPhone and foo~ipad.png on an iPad, etc. These suffixes also work when loading ImageMap plists and 3D model files, so you can provider higher-res versions for Retina displays.

This is an elegant solution for apps, but is sometimes insufficient for games because, unlike apps, hybrid games often share near-identical interfaces on iPhone and iPad, with the assets and interface elements simply scaled up, and this means that the standard definition iPad and Retina resolution iPhone need to use the same images.

Naming your images with the @2x suffix works for iPhone but not iPad, and naming them with the ~ipad suffix works for iPad but not iPhone, which forces you to either duplicate identical assets with different filenames, or to write your own file loading logic.

The -hd suffix is a concept introduced by the Cocos2D library to solve the problem of wanting to use the same @2x graphics for both the iPhone Retina display and the iPad standard definition display by using the same -hd filename suffix for both.

The GLView library has no built-in support for the -hd suffix, however if you include the StandardPaths library (https://github.com/nicklockwood/StandardPaths) in your project, GLView will use this library to automatically add support for the -hd suffix to GLImage, GLImageMap and GLModel, as well as other suffixes supported by the StandardPaths library, such as -568h for iPhone 5-specific assets.


PVR images
--------------

The PVR image format is a special proprietary image format used by the PowerVR graphics chip in iOS devices. PVR images load quicker and can take up less space in memory than PNGs, so they can be very useful for apps that need to load and display a lot of images.

Due to the rapid loading, they can also be streamed off disk fast enough to create movie clips, which can be a handy way to display video if the standard movie player APIs don't meet your requirements (e.g. if you need video with transparent portions).

You will probably notice when creating PVRs that the file size is actually larger than the equivalent PNG file. This is misleading however - PNG files use internal zip compression which makes them small on disk, but when they are loaded into memory they are expanded to consume an amount of space equivalent to their width * height * 4 bytes.

The same is true of JPEG or any other image format. But with PVR, the size on disk matches the size in memory, so a 16-bit PVR only consumes half as much memory as a PNG of the same dimensions, and a compressed PVR takes up even less space. Since the structure on disk is exactly the same as in memory, PVRs also load quicker because there is no need to decompress or transcode them.

PVRs are restricted to square images with power-of-two sizes however. See the note below about conversion.
	

Generating PVR image files
----------------------------

GLImage can load PVR images, which are a special format used by iOS graphics chips that is extremely memory efficient and fast to load. Often, images that you would have to load using a background thread if they were PNG or JPEG format in order to avoid blocking the UI can be loaded in real time on the main thread with no performance impact if you use PVR format instead.

To generate PVR images, your best option is to use the Imagination PVRTexTool, which you can download as part of the PVR SDK from here: http://www.imgtec.com/powervr/insider/sdkdownloads/

The SDK is free to download (though registration is reauired) and includes a fairly easy-to-use GUI tool, and a very powerful command-line tool. The PVRTexTool can be used to batch convert a PNG images to PVR in all known formats.

**NOTE:** In addition to needing power-of-two dimensions, PVR images must also be perfectly square, i.e. the width and height must be equal. Valid sizes are 2x2, 4x4, 8x8, 16x16, 32x32, 64x64, 128x128, 256x256, etc. Remember to crop or scale your images to a valid size before converting them.

Once installed, you can find the command-line PVRTexTool at:

    /Applications/Imagination/PowerVR/GraphicsSDK/PVRTexTool/CL/OSX_x86/PVRTexToolCL

GLImage currently only supports the legacy PVR version 2 texture format. The PVRTexTool supports this using the -legacypvr option. If your image contains transparency, you will also want to enable premultiplied alpha using the -p option.

Typical texturetool settings you might want to use are:

    /Applications/Imagination/PowerVR/GraphicsSDK/PVRTexTool/CL/OSX_x86/PVRTexToolCL -i {input_file_name}.png -o {output_file_name}.pvr -legacypvr -p -l -f PVRTC1_4 -q pvrtcbest

This generates a 4 bpp compressed PVR image with alpha at best available compression quality. This will take several seconds to run, so don't be alarmed.

If you will need to zoom your images, or view them at greatly reduced size in the app, it's a good idea to enable mipmapping in order to improve the quality of the image when drawn at smaller sizes. Mipmapping increases the size of the PVR file on disk and in memory by about 33%, so don't use it if you are only planning to display your images at 100% size or higher. To enable mipmapping, add the -m flag and use the -mfilter flag to specify mipmapping algorithm:

    /Applications/Imagination/PowerVR/GraphicsSDK/PVRTexTool/CL/OSX_x86/PVRTexToolCL -i {input_file_name}.png -o {output_file_name}.pvr -legacypvr -p -l -m -mfilter cubic -f PVRTC1_4 -q pvrtcbest
    
This generates a 4 bpp compressed PVR image with alpha and mipmaps.

As stated previously, these files will appear like compressed JPEG images, and may not be appropriate for user interface components or images with fine detail. They are better for large photos or images that would load too slowly or use up too much memory if stored in a lossless format such as PNG. However, it is also possible to create PVR images in a variety of higher, non-compressed format by specifying a different value for the -f flag. Available formats are:

    - RGBG8888 - 32 bits-per-pixel, high quality 24-bit colour with 8-bit alpha
    - ETC2_RGBA - 16 bits-per-pixel, 12-bit colour and 4-bit alpha
    - ETC2_RGB_A1 - 16 bits-per-pixel, higher precision 5-bit color but only 1-bit alpha
    - ETC2_RGB - 16 bits-per-pixel, higher precision color, but no alpha transparency
    - PVRTC1_4 - 4 bits-per-pixel lossy compression, with alpha
    - PVRTC1_4_RGB - 4 bits-per-pixel lossy compression, without alpha
    - PVRTC1_2 - 2 bits-per-pixel lossy compression, with alpha
    - PVRTC1_2_RGB - 2 bits-per-pixel lossy compression, without alpha
    
To batch convert a folder of images, just CD to the directory containing your images then run the following command:

    find ./ -name \*.png | sed 's/\.png//g' | \ xargs -I % -n 1 /Applications/Imagination/PowerVR/GraphicsSDK/PVRTexTool/CL/OSX_x86/PVRTexToolCL -i %.png -o %.pvr -legacypvr -p -l -m -mfilter cubic -f PVRTC1_4 -q pvrtcbest
    
This will apply the PVRTexTool command to each file in the folder in turn.
    

Generating PVR video clips
----------------------------

To use the GLImageView as a PVR video player, you'll need to convert your video into a sequence of PVR images. Assuming you are starting with a Quicktime-compatible video file, follow these steps. If you've already got your video as a sequence of numbered PNG or JPEG images then you can skip to step 4.

1) Open your video in QuickTime 7 (not Quicktime X). You'll need a QuickTime Pro license to do anything useful.

2) Assuming the video isn't already a square with power-of-two sides, you first need to convert it to the correct aspect ratio. Select Export... and choose 'Movie to MPEG-4'. Within this interface you can select a custom width and height. Go for the nearest square power-of-two dimensions to the actual video size, and you're probably better off choosing to crop or scale the image than letterbox it. Go for the highest quality you can to avoid compression artefacts.

3) After exporting your video as an MP4, open the new video in QuickTime 7 and go to the export option again. This time select 'Movie to Image Sequence' and export the video as a sequence of PNG files.

4) Now that you have the individual frames, you'll need to convert them to PVRs. Use the batch conversion technique listed above (you may wish to tweak the format, quality, etc. depending on whether your movie has transparency):

	find ./ -name \*.png | sed 's/\.png//g' | \ xargs -I % -n 1 /Applications/Imagination/PowerVR/GraphicsSDK/PVRTexTool/CL/OSX_x86/PVRTexToolCL -i %.png -o %.pvr -legacypvr -p -l -f PVRTC1_4 -q pvrtcbest
	
This generates the frames as 4 bpp compressed PVR images with alpha (this will take a very long time, you may want to get a coffee). Since the individual image frames will still be quite large, you may now wish to gzip them by running:

    find ./ -name \*.pvr | sed 's/\.pvr//g' | xargs -I % -n 1  gzip %.pvr
    
(See below for details on gzipped images).

5) You can now pass an array containing the image names to the GLImageView class `animationImages` property to play your images in sequence (remember to pass the image file names, not the images themselves as this will reduce memory usage and avoid a long delay when the images first load).


Gzipping PVR Images
----------------------------

PVR image sequences are very large compared with the original MP4 movie, or even the equivalent PNG image sequence. PVR is optimised for memory usage and loading speed, not disk space, so be prepared for your app to grow dramatically if you include a lot of PVR images. To reduce the size of your PVR images on disk you can gzip them, which can reduce their size significantly, depending on the image content. To gzip a pvr image, you can use the following command line tool:

    gzip {image_file}
    
To individually gzip a folder of PVR images, CD to the image folder, then you can use the following command:

    find ./ -name \*.pvr | sed 's/\.pvr//g' | xargs -I % -n 1  gzip %.pvr

You can load the zipped images by including the GZIP library in your project (https://github.com/nicklockwood/Gzip). The GLImage class will automatically detect the presence of the GZIP library and unzip the images when loading them.

The GLModel class also supports gzip, so if you have very large model files you may want to try gzipping them to reduce your app size.


Premultiplied Alpha
---------------------

Images with an alpha channel can be generated with either straight or premultiplied alpha. Typically on iOS, images use premultiplied alpha because it is more efficient for rendering. PNG images added to your Xcode project will be automatically converted to use premultiplied alpha, so GLImage assumes premultiplied alpha when loading images.

When using PVR images, straight alpha can result in a one-pixel black or white halo around the opaque parts of the image when rendered (you can see slight white halos in the PVR images in the GLImage demo), so it's recommended that you use premultiplied alpha with PVR images, which can be achieved using the PVRTexTool by adding the -p flag (this is already included in the examples above).

At present, there's no way to automatically detect the type of alpha when loading a PVR image, so if you have generated your PVRs with straight alpha, GLImage will still assume they are premultiplied, which will make them look even worse when they are displayed. To correct this, call `[image imageWithPremultipliedAlpha:NO]` on the image after loading it to create a copy that will treat the image as having straight alpha instead.

The Cocos2D Plist file format supported by GLImageMap includes metadata indicating whether the texture file has premultiplied alpha or not, so no further work is needed when loading sprite sheets with GLImageMap.