# MHMimeType

`Objective-c` check MIME type based on magic bytes. `MHMimeType` detects MIME type of a `NSData`. Inspired by [sendyhalim/Swime](https://github.com/sendyhalim/Swime)

## Requirements

- iOS 8.0+
- Xcode 9.0+

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```
$ brew update
$ brew install carthage
```

To integrate MHMimeType into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "MakeHui/MHMimeType"
```

Run `carthage update` to build the framework and drag the built `MHMimeType` into your Xcode project.

## Usage

```objc
#import <MHMimeType/MHMimeType.h>

NSString *path = @"file:///Users/ShungYin/Desktop/1.jpg";
MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithPath:[NSString stringWithFormat:@"file://%@", path]];
//    MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithURL:URL];
//    MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithData:data];

NSLog(@"%@", model.mime);
NSLog(@"%@", model.ext);
NSLog(@"%lu", (unsigned long)model.type);
```

## License

MHMimeType is released under the MIT license. See LICENSE for details.
