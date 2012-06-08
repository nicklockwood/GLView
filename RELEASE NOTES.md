Version 1.3.2

- Added support for the Cocos2D -hd file suffix
- Fixed bug in ~ipad file suffix handling
- Added File Suffixes test project
- Added GLUtils class documentation
- Extended the documentation with info about file suffix handling

Version 1.3.1

- Added support for trimmed sprites to GLImageMap
- Added support for aliased images in GLImageMap
- Image, ImageMap and model file loading now recognises ~ipad suffix for iPad-specific asset versions.
- Added contentRect property to GLImage
- Added vertexCoords property to GLImage

Version 1.3

- Added GLImageMap class, with support for loading Cocos2D sprite sheets
- Added image map example to GLImage Demo
- Added ability to specify if GLImage has premultiplied alpha
- Added ability to create GLImages and GLModels from preloaded data
- Added ability to specify image size, scale and clipRect
- Updated PVR image documentation for Xcode 4.3 and above

Version 1.2.2

- Fixed bug with images being rendered at half size on retina display
- GLImage now supports non power-of-two-sized images
- Added initWithSize:scale:drawingBlock: method to GLImage for creating images with content drawn at runtime
- Fixed a bug in GLImageView initWithImage method
- Fixed some leaks in GLModel loading code when not running under ARC
- GLView animation step method is no longer called if the view is offscreen

Version 1.2.1

- Added GLLight object
- Added lights property to GLModelView
- Fixed intermittent crash when loading .obj models that have normals but do not have texture coordinates (e.g. cube.obj)

Version 1.2

- Added GLModel and GLModelView for loading and displaying polygonal models
- Added UIIMage+GL category for easy conversion of UIColors to OpenGL format
- Extended image example with additional formats
- Fixed crash when attempting to load non-existent image files
- Added ARC support

Version 1.1.1

- Expanded example app to demonstrate relative quality and loading time of different formats

Version 1.1

- Added animated image sequence playback to GLImageView
- Added PVR video demo to the example project

Version 1.0

- Initial release