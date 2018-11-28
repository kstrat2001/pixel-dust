# pixel-dust
A GPU Image Processing Library for iOS

PixelDust is a CocoaPod framework for iOS that performs GPU accelerated image processing on UIImages.

Currently features are limited to an ImageComparator that can tell you if 2 images are different and provide an output image that shows the diffs.

The ImageComparator is built for use in an Xcode test environment which means it has to run on the simulator (no Metal support).  Thus ImageComparator is written in Objective-C using OpenGL shaders to execute diffs.

## Installation

In your Podfile:

```
target 'MyTarget' do
    pod 'PixelDust', :git => 'git@github.com:kstrat2001/pixel-dust.git', :branch => 'master'
end
```

Or specify a tag (see releases tab in github):

```
target 'MyTarget' do
    pod 'PixelDust', :git => 'git@github.com:kstrat2001/pixel-dust.git', :tag => 'v0.1.5'
end
```

## ImageComparator

Create a comparator:

```
// Initialize resources to re-use the comparator
var imageComparator = ImageComparator()
```

or

```
// Initialize with images
let comparator = ImageComparator(image: UIImage(named: "image1")!, image2: UIImage(named: "image-different")!)
```

Set the images:

```
comparator.setImage(uiImage1, image2: uiImage2)
```

Compare:

```
if comparator.compare() {
    print("The images are the same!")
}
```

Generate/Get a diff image:

```
// Pass in true to amplify the diff
// This makes any pixel that was different a stronger color, making it easier to see pixels that are different
let diffImage = comparator.getDiffImage(true)
```

or, for a diff where color magnitude is the difference

```
let diffImage = comparator.getDiffImage()
```
