Version 1.0.3

- Removed 4.0-specific API reference so that WebContentView can be used on iOS 3.x
- Added -webkit-touch-callout: none; to the default stylesheet to prevent popup when touching links or images.

Version 1.0.2

- Fixed performance issues when scrolling large amounts of content.

Version 1.0.1

- Added -webkit-text-size-adjust: none to default css to prevent arbitrary text resizing on iPhone.
- Renamed defaultStyles to sharedStyles and modified behaviour so that sharedStyles are applied after default style settings.
- Added IBOutlet tag to delegate property so it can be set in Interface Builder.
- Extended example to include delegate functionality

Version 1.0

- Initial release