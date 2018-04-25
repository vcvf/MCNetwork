//
//  MCViewController.m
//  MCNetwork
//
//  Created by 1594717129@qq.com on 04/03/2018.
//  Copyright (c) 2018 1594717129@qq.com. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MCViewController.h"
#import "NormalRequest.h"
#import "DownloadRequest.h"
#import "UploadRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "MCDownloadAdvancedViewController.h"
#import <MCNetwork/MCNetwork.h>

#define InheritRequest 1
#define CenterRequest_Normal 0
#define CenterRequest_AppointClass 0

@interface MCViewController () <MCRequestAccessory> {
    NormalRequest *_normalRequest;
    DownloadRequest *_downloadRequest;
}

@property (weak, nonatomic) IBOutlet UITextView *respTextView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopDownloadBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadProgressLab;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *uploadProgressLab;

@end

@implementation MCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *suffix = @"";
    if (InheritRequest) {
        suffix = @"继承请求";
    } else if (CenterRequest_Normal) {
        suffix = @"MCRequestCenter_Normal请求";
    } else if (CenterRequest_AppointClass) {
        suffix = @"MCRequestCenter_指定类名请求";
    }
    self.navigationItem.title = [NSString stringWithFormat:@"Demo-%@", suffix];
	
    self.respTextView.editable = NO;
    self.respTextView.text = nil;
    self.downloadBtn.enabled = YES;
    self.stopDownloadBtn.enabled = NO;
    self.downloadProgressView.progress = 0;
    self.downloadProgressLab.text = nil;
    self.uploadProgressView.progress = 0;
    self.uploadProgressLab.text = nil;
    
    
    [MCNetworkConfig sharedConfig].debugLogEnabled = YES;
}

#pragma mark - Base Request

- (IBAction)httpLoad:(id)sender {
    self.respTextView.text = nil;
    
    if (InheritRequest) {
        [self httpLoad_Inherit];
    } else if (CenterRequest_Normal) {
        [self httpLoad_Center_Normal];
    } else if (CenterRequest_AppointClass) {
        [self httpLoad_Center_AppointClass];
    }
}


/**
 基本网络请求,采用继承MCBaseRequest的方式
 */
- (void)httpLoad_Inherit {
    self.respTextView.text = nil;
    
    NormalRequest *request = [[NormalRequest alloc] init];
    request.tag = 100;
    [request addAccessory:self];
    
    [request startWithCompletionBlockWithSuccess:^(MCBaseRequest * _Nonnull req) {
        self.respTextView.text = [NSString stringWithFormat:@"%@", req.responseObject];
        NSLog(@"%@", req.response);
        NSLog(@"%lu", (unsigned long)req.hash);
    } failure:^(MCBaseRequest * _Nonnull req) {
        self.respTextView.text = [NSString stringWithFormat:@"Request Failure: %@", req];
    }];    
}


/**
 采用类方法调用请求,无须自己初始化请求对象
 */
- (void)httpLoad_Center_Normal {
    [MCRequestCenter sendRequest:^(MCBaseRequest *request) {
        request.baseUrl = @"http://api.ecook.cn";
        request.requestUrl = @"/public/getHomeData.shtml";
        request.tag = 100;
        [request addAccessory:self];
    } success:^(MCBaseRequest * _Nonnull request) {
        self.respTextView.text = [NSString stringWithFormat:@"%@", request.responseObject];
    } failure:^(MCBaseRequest * _Nonnull request) {
        self.respTextView.text = [NSString stringWithFormat:@"Request Failure: %@", request];
    }];
}


/**
 采用类方法调用请求,并且指定一个请求类,存在于某些,项目中采用了一个基类继承与MCBaseRequest, 这时候不需要自己初始化请求对象,也可以调用类方法
 */
- (void)httpLoad_Center_AppointClass {
    [MCRequestCenter sendRequestByAppointedClass:[NormalRequest class] configBlock:nil success:^(MCBaseRequest * _Nonnull request) {
        self.respTextView.text = [NSString stringWithFormat:@"%@", request.responseObject];
    } failure:^(MCBaseRequest * _Nonnull request) {
        self.respTextView.text = [NSString stringWithFormat:@"Request Failure: %@", request.error];
    }];
}

#pragma mark - DownLoad

- (IBAction)downLoad:(UIButton *)sender {
    self.downloadBtn.enabled = NO;
    self.stopDownloadBtn.enabled = YES;
    self.downloadProgressView.progress = 0;
    self.downloadProgressLab.text = nil;
    
    if (InheritRequest) {
        [self startDownload_Inherit];
    } else if (CenterRequest_Normal) {
        [self startDownload_Center_Normal];
    } else if (CenterRequest_AppointClass) {
        [self startDownload_Center_AppointClass];
    }
}

- (void)startDownload_Inherit {
    DownloadRequest *request = [[DownloadRequest alloc] init];
    request.advanced = NO;
    request.tag = 200;
    [request addAccessory:self];
    
    [request startWithDownloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        self.downloadProgressView.progress = downloadProgress.fractionCompleted;
        self.downloadProgressLab.text = [NSString stringWithFormat:@"%.2f%%",downloadProgress.fractionCompleted * 100];
    } success:^(__kindof MCBaseRequest * _Nonnull request) {
        self.downloadBtn.enabled = YES;
        self.stopDownloadBtn.enabled = NO;
        
        NSURL *fileUrl = request.responseObject;
        long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileUrl.path error:NULL] fileSize];
        NSString *fileSizeT = [NSString stringWithFormat:@"文件大小: %.2f -- %lld", fileSize / (1024.0 * 1024.0), fileSize];
        self.respTextView.text = fileSizeT;
    } failure:^(__kindof MCBaseRequest * _Nonnull request) {
        self.downloadBtn.enabled = YES;
        self.stopDownloadBtn.enabled = NO;
    }];
    
    _downloadRequest = request;
}

- (void)startDownload_Center_Normal {
    _downloadRequest = [MCRequestCenter sendRequest:^(__kindof MCBaseRequest * _Nonnull request) {
        request.requestUrl = @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2961/recorder20171119205155.mp4";
        request.requestMethod = MCRequestMethodGET;
        request.downloadFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", request.requestUrl.lastPathComponent];
        request.tag = 200;
        [request addAccessory:self];
    } progressBlock:^(NSProgress * _Nonnull progress) {
        self.downloadProgressView.progress = progress.fractionCompleted;
        self.downloadProgressLab.text = [NSString stringWithFormat:@"%.2f%%",progress.fractionCompleted * 100];
    } success:^(__kindof MCBaseRequest * _Nonnull request) {
        self.downloadBtn.enabled = YES;
        self.stopDownloadBtn.enabled = NO;
        
        NSURL *fileUrl = request.responseObject;
        long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileUrl.path error:NULL] fileSize];
        NSString *fileSizeT = [NSString stringWithFormat:@"文件大小: %.2f -- %lld", fileSize / (1024.0 * 1024.0), fileSize];
        self.respTextView.text = fileSizeT;
    } failure:^(__kindof MCBaseRequest * _Nonnull request) {
        self.downloadBtn.enabled = YES;
        self.stopDownloadBtn.enabled = NO;
    }];
}

- (void)startDownload_Center_AppointClass {
    _downloadRequest = [MCRequestCenter sendRequestByAppointedClass:[DownloadRequest class] configBlock:^(__kindof MCBaseRequest * _Nonnull request) {
        DownloadRequest *downloadRequest = request;
        downloadRequest.advanced = NO;
        downloadRequest.tag = 200;
        [downloadRequest addAccessory:self];
    } progressBlock:^(NSProgress * _Nonnull progress) {
        self.downloadProgressView.progress = progress.fractionCompleted;
        self.downloadProgressLab.text = [NSString stringWithFormat:@"%.2f%%",progress.fractionCompleted * 100];
    } success:^(__kindof MCBaseRequest * _Nonnull request) {
        self.downloadBtn.enabled = YES;
        self.stopDownloadBtn.enabled = NO;
        
        NSURL *fileUrl = request.responseObject;
        long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileUrl.path error:NULL] fileSize];
        NSString *fileSizeT = [NSString stringWithFormat:@"文件大小: %.2f -- %lld", fileSize / (1024.0 * 1024.0), fileSize];
        self.respTextView.text = fileSizeT;
    } failure:^(__kindof MCBaseRequest * _Nonnull request) {
        self.downloadBtn.enabled = YES;
        self.stopDownloadBtn.enabled = NO;
    }];
}

- (IBAction)stopDownload:(UIButton *)sender {
    self.downloadBtn.enabled = YES;
    self.stopDownloadBtn.enabled = NO;
    
    [_downloadRequest stop];
}

- (IBAction)playAction:(id)sender {
    NSURL *urlPath = (NSURL *)_downloadRequest.responseObject;
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:urlPath];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    playerVC.player = player;
    
    [self presentViewController:playerVC animated:YES completion:^{
        [playerVC.player play];
    }];
}

- (IBAction)advancedDownload:(id)sender {
    MCDownloadAdvancedViewController *vc = [[MCDownloadAdvancedViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Upload

- (IBAction)upload:(UIButton *)sender {
    sender.enabled = NO;
    
    UploadRequest *request = [[UploadRequest alloc] init];
    request.tag = 300;
    [request addAccessory:self];
    
    [request startWithUploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        self.uploadProgressView.progress = uploadProgress.fractionCompleted;
        self.uploadProgressLab.text = [NSString stringWithFormat:@"%.2f%%",uploadProgress.fractionCompleted * 100];
    } success:^(__kindof MCBaseRequest * _Nonnull request) {
        sender.enabled = YES;
        
        NSLog(@"图片上传成功: %@", request.responseObject);
    } failure:^(__kindof MCBaseRequest * _Nonnull request) {
        sender.enabled = YES;
    }];
}


#pragma mark - MCRequestAccessory

- (void)requestWillStart:(MCBaseRequest *)request {}

- (void)requestWillStop:(MCBaseRequest *)request {}

- (void)requestDidStop:(MCBaseRequest *)request {
    NSLog(@"已经结束: %ld", (long)request.tag);
}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}

- (IBAction)next:(id)sender {
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MCViewController *vc = [st instantiateViewControllerWithIdentifier:@"MCViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
