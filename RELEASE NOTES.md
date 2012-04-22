Version 1.1

- Less is more! Removed the styles property of the WebContentView to encourage use of the setSharedStyles method instead, which is more performant and less glitchy.
- Added new minimumContentHeight property to control the placement of the footer view (default placement is now different from earlier versions - check the documentation.)
- Renamed header and footer to headerView and footerView.
- Improved performance when first displaying a view by preloading WebKit.

Version 1.0.4

- Fixed race condition where setting web content could cause infinite loop.

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