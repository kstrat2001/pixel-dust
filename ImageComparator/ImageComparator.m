//
//  ImageComparator.m
//
//  Created by Kain Osterholt on 10/27/18.
//  Copyright © 2018 Kain Osterholt. All rights reserved.
//

#import "ImageComparator.h"

//#define DEBUG_GL_ERRORS

float quadVertices[] = {
    // positions   // texCoords
    -1.0f,  1.0f,  0.0f, 1.0f,
    -1.0f, -1.0f,  0.0f, 0.0f,
    1.0f, -1.0f,  1.0f, 0.0f,

    -1.0f,  1.0f,  0.0f, 1.0f,
    1.0f, -1.0f,  1.0f, 0.0f,
    1.0f,  1.0f,  1.0f, 1.0f
};

// point position in center of viewport
float pointVert[] = {
    0.0f, 0.0f
};

// Max image size equal to iPhone XS Max (landscape or portrait)
#define IMAGE_MAX_WIDTH  2688
#define IMAGE_MAX_HEIGHT 2688

// Used to temporarily get texture data in and out of UIKit constructs
static GLubyte data[IMAGE_MAX_WIDTH * IMAGE_MAX_HEIGHT * 4];

@implementation ImageComparator

@synthesize image1Width = _image1Width, image1Height = _image1Height;
@synthesize image2Width = _image2Width, image2Height = _image2Height;

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        [self initializeResources];
        _imagesSet = false;
    }

    return self;
}

-(id)initWithImage:(UIImage*)image1 image2:(UIImage*)image2;
{
    self = [super init];
    if(self != nil)
    {
        [self initializeResources];
        [self setImage:image1 image2:image2];
    }

    return self;
}

-(void)initializeResources
{
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:_context];
    glDisable(GL_DEPTH_TEST);

    // Create render target for 1x1 super sample compare
    glGenFramebuffers(1, &_compareRenderTarget);
    glGenTextures(1, &_compareRenderTargetTex);

    // Create render target for iamge wxh diff result
    glGenFramebuffers(1, &_diffRenderTarget);
    glGenTextures(1, &_diffRenderTargetTex);

    glGenTextures(1, &_image1Tex);
    glGenTextures(1, &_image2Tex);

    glGenVertexArrays(1, &_quadVAO);
    glGenBuffers(1, &_quadVBO);
    glBindVertexArray(_quadVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _quadVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)(2 * sizeof(float)));

    // VAO for a point in the center of the viewport
    glGenVertexArrays(1, &_pointVAO);
    glGenBuffers(1, &_pointVBO);
    glBindVertexArray(_pointVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _pointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(pointVert), &pointVert, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)0);

    _compareVtxShader = [self compileShader:@"super_sample_compare" withType:GL_VERTEX_SHADER];
    _compareFrgShader = [self compileShader:@"super_sample_compare" withType:GL_FRAGMENT_SHADER];
    _compareProgram = [self createProgramWithShaders:_compareVtxShader fragmentShader:_compareFrgShader];

    _diffVtxShader = [self compileShader:@"diff" withType:GL_VERTEX_SHADER];
    _diffFrgShader = [self compileShader:@"diff" withType:GL_FRAGMENT_SHADER];
    _diffProgram = [self createProgramWithShaders:_diffVtxShader fragmentShader:_diffFrgShader];

    _diffAmpVtxShader = [self compileShader:@"diff_amp" withType:GL_VERTEX_SHADER];
    _diffAmpFrgShader = [self compileShader:@"diff_amp" withType:GL_FRAGMENT_SHADER];
    _diffAmpProgram = [self createProgramWithShaders:_diffVtxShader fragmentShader:_diffFrgShader];

    // Bind shaders and set variables
    glUseProgram(_compareProgram);
    int tex2Location = glGetUniformLocation(_compareProgram, "img2");
    glUniform1i(tex2Location, 1);

    // Bind shaders and set variables
    glUseProgram(_diffProgram);
    tex2Location = glGetUniformLocation(_diffProgram, "img2");
    glUniform1i(tex2Location, 1);

    glUseProgram(_diffAmpProgram);
    tex2Location = glGetUniformLocation(_diffAmpProgram, "img2");
    glUniform1i(tex2Location, 1);

    [self checkGLError:@"init"];
}

-(void)dealloc
{
    glDeleteBuffers(1, &_compareRenderTarget);
    glDeleteBuffers(1, &_diffRenderTarget);
    glDeleteBuffers(1, &_quadVAO);
    glDeleteBuffers(1, &_quadVBO);
    glDeleteBuffers(1, &_pointVAO);
    glDeleteBuffers(1, &_pointVBO);

    glDeleteTextures(1, &_compareRenderTargetTex);
    glDeleteTextures(1, &_diffRenderTargetTex);
    glDeleteTextures(1, &_image1Tex);
    glDeleteTextures(1, &_image2Tex);

    glDeleteShader(_compareVtxShader);
    glDeleteShader(_compareFrgShader);
    glDeleteShader(_compareProgram);

    glDeleteShader(_diffVtxShader);
    glDeleteShader(_diffFrgShader);
    glDeleteShader(_diffProgram);

    glDeleteShader(_diffAmpVtxShader);
    glDeleteShader(_diffAmpFrgShader);
    glDeleteShader(_diffAmpProgram);

    _context = nil;
}

-(void)checkGLError:(NSString*)tag
{
#ifdef DEBUG_GL_ERRORS
    GLenum err;
    while ((err = glGetError()) != GL_NO_ERROR) {
        NSLog(@"OpenGL error: %x in tag %@", err, tag);
    }
#endif
}

-(BOOL)dimensionsMatch
{
    return (_image1Width == _image2Width && _image1Height == _image2Height);
}

-(void)resetGLState
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindVertexArray(0);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glUseProgram(0);
}

-(BOOL)compare
{
    if(!_imagesSet || ![self dimensionsMatch])
    {
        return false;
    }

    [EAGLContext setCurrentContext:_context];

    glViewport(0, 0, 1, 1);
    glUseProgram(_compareProgram);
    int widthLoc = glGetUniformLocation(_compareProgram, "width");
    glUniform1f(widthLoc, (GLfloat)_image1Width);
    int heightLoc = glGetUniformLocation(_compareProgram, "height");
    glUniform1f(heightLoc, (GLfloat)_image1Height);
    
    // Bind fbo to draw into
    glBindFramebuffer(GL_FRAMEBUFFER, _compareRenderTarget);

    // Bind quad vtx array object
    glBindVertexArray(_pointVAO);

    // Bind textures
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _image2Tex);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _image1Tex);

    // Draw some!
    glDrawArrays(GL_POINTS, 0, 1);

    [self checkGLError:@"compare"];
    [self resetGLState];

    return [self getDiffFactor] == 0.0f;
}

-(float)getDiffFactor
{
    [EAGLContext setCurrentContext:_context];

    glBindFramebuffer(GL_FRAMEBUFFER, _compareRenderTarget);

    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, data);

    [self checkGLError:@"getDiffFactor"];
    [self resetGLState];

    return (float)(data[0] + data[1] + data[2]);
}

-(UIImage*)getDiffImage
{
    return [self getDiffImage:false];
}

-(UIImage*)getDiffImage:(BOOL)amplify
{
    GLsizei width  = _image1Width;
    GLsizei height = _image1Height;

    [EAGLContext setCurrentContext:_context];

    glViewport(0, 0, width, height);

    // Bind fbo to draw into
    glBindFramebuffer(GL_FRAMEBUFFER, _diffRenderTarget);

    // Bind quad vtx array object
    glBindVertexArray(_quadVAO);

    // Bind textures
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _image2Tex);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _image1Tex);

    // Bind shaders and set variables
    if(amplify)
    {
        glUseProgram(_diffAmpProgram);
    }
    else
    {
        glUseProgram(_diffProgram);
    }

    // Draw the entire quad (2 triangles)
    glDrawArrays(GL_TRIANGLES, 0, 6);

    NSInteger dataLength = width * height * 4;

    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);

    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);

    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, width, height), iref);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);

    [self checkGLError:@"getDiffImage"];
    [self resetGLState];

    return image;
}

-(void)setImage:(UIImage*)image1 image2:(UIImage*)image2
{
    [EAGLContext setCurrentContext:_context];

    _image1Width = image1.size.width;
    _image1Height = image1.size.height;

    _image2Width = image2.size.width;
    _image2Height = image2.size.height;

    NSAssert(_image1Width <= IMAGE_MAX_WIDTH &&
             _image2Width <= IMAGE_MAX_WIDTH &&
             _image1Height <= IMAGE_MAX_HEIGHT &&
             _image2Height <= IMAGE_MAX_HEIGHT, @"Can't support images larger than full screen iPhone XS Max");

    [self createDiffRenderTarget];
    [self createCompareRenderTarget];

    [self convert:image1 toTexture:_image1Tex];
    [self convert:image2 toTexture:_image2Tex];

    _imagesSet = true;
}

-(void)convert:(UIImage*)image toTexture:(GLuint)texture
{
    GLsizei width  = image.size.width;
    GLsizei height = image.size.height;

    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(data, width, height,
                                                 bitsPerComponent, bytesPerRow, CGImageGetColorSpace(image.CGImage),
                                                 kCGImageAlphaPremultipliedLast);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    CGContextRelease(context);

    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);

    [self checkGLError:@"convert"];
}

// Create the render target texture for the diff image
-(void)createDiffRenderTarget
{
    [self initializeRenderTarget:_diffRenderTarget
                     withTexture:_diffRenderTargetTex
                        withSize:CGSizeMake(_image1Width, _image1Height)];
}

// Create a 1x1 target texture and FBO for the simple super-sampling compare
-(void)createCompareRenderTarget
{
    [self initializeRenderTarget:_compareRenderTarget
                     withTexture:_compareRenderTargetTex
                        withSize:CGSizeMake(1, 1)];
}

-(void)initializeRenderTarget:(GLuint)targetFBO withTexture:(GLuint)glTexture withSize:(CGSize)size
{
    [EAGLContext setCurrentContext:_context];

    glBindFramebuffer(GL_FRAMEBUFFER, targetFBO);

    glBindTexture(GL_TEXTURE_2D, glTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei)size.width, (GLsizei)size.height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, 0);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, glTexture, 0);

    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Render target failed to initialize");
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    [self checkGLError:@"createCompareRenderTarget"];
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    // Open the file
    NSString* shaderExtension = shaderType == GL_VERTEX_SHADER ? @"vtx" : @"frg";
    NSString* shaderPath = [[NSBundle bundleForClass:[self class]] pathForResource:shaderName
                                                           ofType:shaderExtension];

    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }

    // Create OpenGL resource
    GLuint shaderHandle = glCreateShader(shaderType);

    // Set shader source string
    const char * shaderStringUTF8 = [shaderString UTF8String];
    GLint shaderStringLength = (GLint)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);

    // Compile
    glCompileShader(shaderHandle);

    // Check the compilation success/failure
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"Error compiling shader: %@.%@", shaderName, shaderExtension);
        NSLog(@"%@", messageString);
        exit(1);
    }

    return shaderHandle;
}

- (GLuint)createProgramWithShaders:(GLuint)vertexShader fragmentShader:(GLuint)fragmentShader
{
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);

    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        NSAssert(false, @"Could not link shader program");
        return 0;
    }

    return programHandle;
}

@end
