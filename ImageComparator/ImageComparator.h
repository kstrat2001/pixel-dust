//
//  ImageComparator.h
//  PixelDust
//
//  Created by Kain Osterholt on 10/27/18.
//  Copyright © 2018 Kain Osterholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageComparator : NSObject
{
@private
    EAGLContext* _context;
    GLuint       _compareRenderTarget;
    GLuint       _compareRenderTargetTex;

    GLuint       _diffRenderTarget;
    GLuint       _diffRenderTargetTex;

    GLuint       _image1Tex;
    GLuint       _image2Tex;

    GLsizei      _image1Width;
    GLsizei      _image1Height;

    GLsizei      _image2Width;
    GLsizei      _image2Height;

    GLuint       _compareVtxShader;
    GLuint       _compareFrgShader;
    GLuint       _compareProgram;

    GLuint       _diffVtxShader;
    GLuint       _diffFrgShader;
    GLuint       _diffProgram;

    GLuint       _diffAmpVtxShader;
    GLuint       _diffAmpFrgShader;
    GLuint       _diffAmpProgram;

    GLuint       _quadVAO;
    GLuint       _quadVBO;

    GLuint       _pointVAO;
    GLuint       _pointVBO;

    BOOL         _imagesSet;
}

// Image 1 dimensions
@property (nonatomic, readonly) GLsizei image1Width;
@property (nonatomic, readonly) GLsizei image1Height;

// Image 2 dimensions
@property (nonatomic, readonly) GLsizei image2Width;
@property (nonatomic, readonly) GLsizei image2Height;

// Load initial graphics resources, buffers, shaders, etc.
-(id)init;

// load resources and set images for comparison
-(id)initWithImage:(UIImage*)image1 image2:(UIImage*)image2;

// set the images to be compared
-(void)setImage:(UIImage*)image1 image2:(UIImage*)image2;

// execute the comparison on the gpu
-(BOOL)compare;

// Only valid directly after calling compare
// The factor is a number representing magnitude of
// differences per quad pixel set.  It is not a normalized
// 0 to 1.0 value, rather magnitude of differences detected
// higher numbers mean more differences among quad pixel
// bilinear samples
-(float)getDiffFactor;

// Get the image that represents the differences in the inputs
-(UIImage*)getDiffImage:(BOOL)amplify;

// Amplify is off by default
-(UIImage*)getDiffImage;

@end

NS_ASSUME_NONNULL_END
