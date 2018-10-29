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

    GLuint       _quadVAO;
    GLuint       _quadVBO;

    GLuint       _pointVAO;
    GLuint       _pointVBO;
}

// Image 1 dimensions
@property (nonatomic, readonly) GLsizei image1Width;
@property (nonatomic, readonly) GLsizei image1Height;

// Image 2 dimensions
@property (nonatomic, readonly) GLsizei image2Width;
@property (nonatomic, readonly) GLsizei image2Height;

// load resources and set images for comparison
-(id)initWithImages:(UIImage*)image1 image2:(UIImage*)image2;

// set the images to be compared
-(void)setImages:(UIImage*)image1 image2:(UIImage*)image2;

// execute the comparison on the gpu
-(BOOL)compare;

// Get the image that represents the differences in the inputs
-(UIImage*)getDiffImage;

@end

NS_ASSUME_NONNULL_END
