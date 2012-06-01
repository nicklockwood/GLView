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