//
//  EIImagePickerController.m
//  自定义相机
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 张博成. All rights reserved.
//

#import "EIImagePickerController.h"
#import "EIPicturePreview.h"
#import <Photos/Photos.h>
#import "EIDefines.h"
#import "UIImagePickerController+BlocksKit.h"
#import "EIImagePickerFlashBar.h"
#import "EICommonHelper.h"
#import "EIImagePickerFocusView.h"

@import CoreMotion;

#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface EIImagePickerController ()<UIGestureRecognizerDelegate>
{
    BOOL isUsingFrontFacingCamera;
}

//***自定义界面****
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *album;

//***AVFoundation
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;

@property(nonatomic,strong)CMMotionManager  *cmmotionManager;
@property(nonatomic,assign)UIDeviceOrientation deviceOrientationNew;

@property (nonatomic, strong)EIImagePickerFocusView *alertFocusView;

@end

@implementation EIImagePickerController

//+ (instancetype)createImagePickerControllerWith:(id<EIImagePickerControllerDelegate>)delegate
//{
// EIImagePickerController *pickerController = [[EIImagePickerController alloc]initWithNibName:@"EIImagePickerController" bundle:nil];
//    
//    pickerController.delegate =delegate;
//    
//    return pickerController;
//
//}

+ (instancetype)createImagePickerController:(DidFinishDissmissWithImageBlock)dismissBlock openAlbum:(OpenAlbumBlock)openAlbumBlock
{
    EIImagePickerController *pickerController = [[EIImagePickerController alloc]initWithNibName:@"EIImagePickerController" bundle:nil];
    pickerController.didmissBlock = dismissBlock;
    pickerController.openAlbumBlock = openAlbumBlock;
    return pickerController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getThumbnailImages];
    
    [self initAVCaptureSession];
    
    [self setupCmmotion];
    
    isUsingFrontFacingCamera = NO;
    
    self.effectiveScale = self.beginGestureScale = 1.0f;
    
}

- (void)dealloc{
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    if (self.session) {
        
        [self.session startRunning];
    }
}

- (BOOL)prefersStatusBarHidden{
    
        return YES;
    
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationSlide;
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
    
}

- (CMMotionManager *)cmmotionManager{
    if (!_cmmotionManager) {
        _cmmotionManager = [[CMMotionManager alloc] init];
    }
    return _cmmotionManager;
}

- (void)setupCmmotion{
    if([self.cmmotionManager isDeviceMotionAvailable]) {
        
        self.cmmotionManager.accelerometerUpdateInterval = .1f;
        
        ESWeakSelf
        
        [self.cmmotionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"%@",error);
                return;
            }
            
            if (accelerometerData.acceleration.x >= 0.75) {//home button left
                __weakSelf.deviceOrientationNew = UIDeviceOrientationLandscapeRight;
            }
            else if (accelerometerData.acceleration.x <= -0.75) {//home button right
                __weakSelf.deviceOrientationNew = UIDeviceOrientationLandscapeLeft;
            }
            else if (accelerometerData.acceleration.y <= -0.75) {
                __weakSelf.deviceOrientationNew = UIDeviceOrientationPortrait;
            }
            else if (accelerometerData.acceleration.y >= 0.75) {
                __weakSelf.deviceOrientationNew = UIDeviceOrientationPortraitUpsideDown;
            }
            else {
                // Consider same as last time
                __weakSelf.deviceOrientationNew = UIDeviceOrientationUnknown;
            }
            
        }];
    }
}

- (void)initAVCaptureSession{
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    [self.session setSessionPreset:AVCaptureSessionPresetMedium];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = CGRectMake(0, 0,kMainScreenWidth, kMainScreenHeight-164);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.backView.layer.masksToBounds = YES;
    
    [self.backView.layer addSublayer:self.previewLayer];
    
    [self addGenstureRecognizer];
    
    _alertFocusView = [[EIImagePickerFocusView alloc]init];
    
    [self.backView addSubview:_alertFocusView];
}

-(void)addGenstureRecognizer{
    
    UITapGestureRecognizer *singleTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.delaysTouchesBegan = YES;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    
    [self.backView addGestureRecognizer:singleTapGesture];
    [self.backView addGestureRecognizer:pinchGesture];
}

-(void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange{
    
    //也可以直接用_videoDevice,但是下面这种更好
    AVCaptureDevice *captureDevice= [_videoInput device];
    NSError *error;
    
    _effectiveScale = 1.0f;
    
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        NSLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    }else{
        [self.session beginConfiguration];
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        [self.session commitConfiguration];
    }
}

-(void)singleTap:(UITapGestureRecognizer *)tapGesture{
    CGPoint touchedPoint = [tapGesture locationInView:self.backView];
    CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:touchedPoint
                                                                   previewLayer:self.previewLayer
                                                                          ports:self.videoInput.ports];
    [self focusAtPoint:pointOfInterest];
    //[self showFocusBox:touchedPoint];
    
    [self.alertFocusView alertAnimateWithPoint:touchedPoint];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [pinchGesture numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [pinchGesture locationOfTouch:i inView:self.backView];
        CGPoint convertedLocation = [self.backView.layer convertPoint:location fromLayer:self.view.layer];
        if ( ! [self.backView.layer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    AVCaptureDevice *captureDevice= [_videoInput device];
    if (allTouchesAreOnThePreviewLayer) {
        _effectiveScale = _beginGestureScale * pinchGesture.scale;
        if (_effectiveScale < 1.0f)
            _effectiveScale = 1.0f;
        if (_effectiveScale > captureDevice.activeFormat.videoMaxZoomFactor)
            _effectiveScale = captureDevice.activeFormat.videoMaxZoomFactor;
        NSError *error = nil;
        if ([captureDevice lockForConfiguration:&error]) {
            [captureDevice rampToVideoZoomFactor:_effectiveScale withRate:100];
            [captureDevice unlockForConfiguration];
        } else {
            //[self passError:error];
        }
    }
}

- (IBAction)switchCameraSegmentedControlClick:(id)sender {
    
    AVCaptureDevicePosition desiredPosition;
    if (isUsingFrontFacingCamera){
        desiredPosition = AVCaptureDevicePositionBack;
    }else{
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
    
    isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
    
}
- (IBAction)flashButtonClick:(EIImagePickerFlashBar *)sender {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL con1 = [device hasTorch];    //支持手电筒模式
    BOOL con2 = [device hasFlash];    //支持闪光模式
    
    
    if (con1 && con2)
    {
        [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
            if (device.flashMode == AVCaptureFlashModeOff) {
                device.flashMode = AVCaptureFlashModeOn;
                [sender setMode:CameraModeOn];
            } else if (device.flashMode == AVCaptureFlashModeOn) {
                device.flashMode = AVCaptureFlashModeAuto;
                [sender setMode:CameraModeAuto];
            } else if (device.flashMode == AVCaptureFlashModeAuto) {
                device.flashMode = AVCaptureFlashModeOff;
                [sender setMode:CameraModeOff];
            }

        }];
    }else{
        NSLog(@"不能切换闪光模式");
    }
    
}
- (IBAction)cancle:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhotoButtonClick:(id)sender {
    
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:self.deviceOrientationNew];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    //[stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    ESWeakSelf
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        UIImage *image =[UIImage imageWithData:jpegData];
        
        EIPicturePreview *preview = [EIPicturePreview createPreview:^(UIImage *originImage) {
            [__weakSelf dismissViewControllerAnimated:YES completion:nil];
            if (__weakSelf.didmissBlock) {
                __weakSelf.didmissBlock(originImage);
            }
        }];
        [preview setPhotoWith:image];
        [__weakSelf.view addSubview:preview];
        [__weakSelf.view bringSubviewToFront:preview];
        
    }];

}
- (IBAction)album:(id)sender {
    
    if (self.openAlbumBlock) {
        self.openAlbumBlock(self);
    }
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}
#pragma mark ---获取相机小图
- (void)getThumbnailImages
{
    [self.album setBackgroundImage:[UIImage imageNamed:@"LoginForheadImage"] forState:UIControlStateNormal];
    if (![EICommonHelper checkPhotoLibraryAuthorizationStatusOnly]) {
        
        return;
    }
    // 获得相机胶卷
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
    });
}

- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
//    for (PHAsset *asset in assets) {
//        // 是否要原图
//        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
//        __block UIImage * image = nil;
//        // 从asset中获得图片
//        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            image = result;
//        }];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.album setBackgroundImage:image forState:UIControlStateNormal];
//        });
//    }
    PHAsset *phAsset = (PHAsset *)assets.lastObject;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = 80 * multiple;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFill options:0 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.album setBackgroundImage:result forState:UIControlStateNormal];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

+ (void)openAlbum:(UIViewController *)presentingVC didFinishPhotoBlock:(void (^)(UIImage *))block{
    
    [EICommonHelper checkPhotoLibraryAuthorizationStatus];
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        pickerController.bk_didFinishPickingMediaBlock = ^(UIImagePickerController *picker, NSDictionary *info){
            UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            __block UIImagePickerController *_picker = picker;
            
            EIPicturePreview *preView = [EIPicturePreview createPreview:^(UIImage *originImage) {
                [_picker dismissViewControllerAnimated:YES completion:nil];
                if (block) {
                    block(originImage);
                }
            }];
            [preView setPhotoWithAlbum:original];
            [picker.view addSubview:preView];
            [picker.view bringSubviewToFront:preView];
        };
        
        pickerController.bk_didCancelBlock = ^(UIImagePickerController *picker){
            [picker dismissViewControllerAnimated:YES completion:nil];
        };
        
        [presentingVC presentViewController:pickerController animated:YES completion:nil];
    }

}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = previewLayer.frame.size;
    
    if ( [previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize] ) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in ports) {
            if (port.mediaType == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            //[self passError:error];
        }
    }
}

//- (void)showFocusBox:(CGPoint)point
//{
//    if(self.focusBoxLayer) {
//        // clear animations
//        [self.focusBoxLayer removeAllAnimations];
//        
//        // move layer to the touch point
//        [CATransaction begin];
//        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
//        self.focusBoxLayer.position = point;
//        [CATransaction commit];
//    }
//    
//    if(self.focusBoxAnimation) {
//        // run the animation
//        [self.focusBoxLayer addAnimation:self.focusBoxAnimation forKey:@"animateOpacity"];
//    }
//}

@end
