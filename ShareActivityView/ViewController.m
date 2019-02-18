//
//  ViewController.m
//  ShareActivityView
//
//  Created by chenjie on 17/4/11.
//  Copyright © 2017年 chenjie. All rights reserved.
//

#import "ViewController.h"
#import "ShareItem.h"
#import "CustomActivity.h"

#import "TYSnapshotScroll.h"

@interface ViewController ()
{
    UIButton *btn;
}

@property (weak, nonatomic) IBOutlet UIImageView *QRcodeView;
@property (weak, nonatomic) IBOutlet UIScrollView *shareView;
@property (weak, nonatomic) IBOutlet UIView *erWeiMaView;

@property (nonatomic,strong) UIImage *shareImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addBtn];
    [self erweima];
    
    
}

- (void)erweima{
    
    //二维码滤镜
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    NSString * selfAddStr = @"https://set.ifangbianmian.com/plus/coupons_share/share.php?num_iid=586005415028";//@"https://detail.tmall.com/item.htm?id=581094958416";
    
    NSData *data = [selfAddStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage = [filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    self.QRcodeView.image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:120.0];
    
    
    //如果还想加上阴影，就在ImageView的Layer上使用下面代码添加阴影
    
    self.QRcodeView.layer.shadowOffset=CGSizeMake(0, 0.5);//设置阴影的偏移量
    
    self.QRcodeView.layer.shadowRadius=1;//设置阴影的半径
    
    self.QRcodeView.layer.shadowColor=[UIColor blackColor].CGColor;//设置阴影的颜色为黑色
    
    self.QRcodeView.layer.shadowOpacity=0.3;
    
}

//改变二维码大小

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}


- (IBAction)shareClick:(UIButton *)sender {
    
    //在需要截图的地方调用此方法
    [TYSnapshotScroll screenSnapshot:self.shareView finishBlock:^(UIImage *snapShotImage) {
        
        self.shareImg = snapShotImage;
        [self addActivityViewController];
        
    }];
    
    

}

-(void)addBtn
{
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-50, 100, 50);
    btn.center = self.view.center;
    [btn setTitle:@"分享" forState:UIControlStateNormal];
    [btn setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addActivityViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}



-(void)addActivityViewController
{
    /**
     第一种：分享类型为纯图片
     */
//    UIImage *imageToShare = [UIImage imageNamed:@"111.jpg"];
//    UIImage *imageToShare1 = [UIImage imageNamed:@"222.jpg"];
//    UIImage *imageToShare2= [UIImage imageNamed:@"333.jpg"];
//    NSArray *itemArr = @[imageToShare,imageToShare1,imageToShare2];
    
    
    /**
     第二种：图片数组为img的本机缓存地址
     */
    UIImage *imageToShare = [UIImage imageNamed:@"111.jpg"];
    UIImage *imageToShare1 = [UIImage imageNamed:@"222.jpg"];
    UIImage *imageToShare2 = [UIImage imageNamed:@"333.jpg"];

    NSArray *activityItems = @[self.shareImg,imageToShare,imageToShare1,imageToShare2];
    
    NSMutableArray *items = [NSMutableArray array];
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];

    for (int i = 0; i < activityItems.count; i++) {
        //图片缓存的地址，自己进行替换
        NSString *imagePath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/ShareWX%d.jpg",i]];
        //把图片写进缓存，一定要先写入本地，不然会分享出错
        [UIImageJPEGRepresentation(activityItems[i], .5) writeToFile:imagePath atomically:YES];
        //把缓存图片的地址转成NSUrl格式
        NSURL *shareobj = [NSURL fileURLWithPath:imagePath];
        //这个部分是自定义ActivitySource
        ShareItem *item = [[ShareItem alloc] initWithData:activityItems[i] andFile:shareobj];
        //分享的数组
        [items addObject:item];
    }
    
    /**
     第三种：图片数组为url的本机缓存地址
            url必须是图片的地址，不是网页的地址
     */
    /*
    NSArray *activityItems = @[
                             @"http://img3.duitang.com/uploads/item/201604/24/20160424132044_ZzhuX.jpeg",
                             @"http://v1.qzone.cc/avatar/201408/03/23/44/53de58e5da74c247.jpg%21200x200.jpg",
                             @"http://img4.imgtn.bdimg.com/it/u=1483569741,1992390913&fm=214&gp=0.jpg"];
    NSMutableArray *items = [NSMutableArray array];
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    for (int i = 0; i < activityItems.count; i++) {
        //取出地址
        NSString *URL = [activityItems[i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //把图片转成NSData类型
         NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL]];
        //写入图片中
        UIImage *imagerang = [UIImage imageWithData:data];
        //图片缓存的地址，自己进行替换
        NSString *imagePath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/ShareWX%d.jpg",i]];
        //把图片写进缓存，一定要先写入本地，不然会分享出错
        [UIImageJPEGRepresentation(imagerang, .5) writeToFile:imagePath atomically:YES];
        //把缓存图片的地址转成NSUrl格式
        NSURL *shareobj = [NSURL fileURLWithPath:imagePath];
        //这个部分是自定义ActivitySource
        ShareItem *item = [[ShareItem alloc] initWithData: imagerang andFile:shareobj];
        //分享的数组
        [items addObject:item];
    }*/
   
    
#pragma mark - 分享功能


    // 1、设置分享的内容，并将内容添加到数组中
    NSString *shareText = @"分享的标题";
//    NSString *shareImage = @"https://img-blog.csdn.net/20161205152600993?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center";
    UIImage *shareImage = [UIImage imageNamed:@"shareImage"];
    NSURL *shareUrl = [NSURL URLWithString:@"https://www.jianshu.com/u/15d37d620d5b"];
    NSArray *activityItemsArray = @[shareText,shareImage,shareUrl];
    
    // 自定义的CustomActivity，继承自UIActivity
    CustomActivity *customActivity = [[CustomActivity alloc]initWithTitle:shareText ActivityImage:[UIImage imageNamed:@"custom.png"] URL:shareUrl ActivityType:@"Custom"];
    NSArray *activityArray = @[customActivity,customActivity];
    
    // 2、初始化控制器，添加分享内容至控制器
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    activityVC.modalInPopover = YES;
    //去除特定的分享功能
    activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter, UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,UIActivityTypeOpenInIBooks];
    // 3、设置回调
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // ios8.0 之后用此方法回调
        UIActivityViewControllerCompletionWithItemsHandler itemsBlock = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
            NSLog(@"activityType == %@",activityType);
            if (completed == YES) {
                NSLog(@"completed");
            }else{
                NSLog(@"cancel");
            }
        };
        activityVC.completionWithItemsHandler = itemsBlock;
    }else{
        // ios8.0 之前用此方法回调
        UIActivityViewControllerCompletionHandler handlerBlock = ^(UIActivityType __nullable activityType, BOOL completed){
            NSLog(@"activityType == %@",activityType);
            if (completed == YES) {
                NSLog(@"completed");
            }else{
                NSLog(@"cancel");
            }
        };
        activityVC.completionHandler = handlerBlock;
    }
    // 4、调用控制器
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
