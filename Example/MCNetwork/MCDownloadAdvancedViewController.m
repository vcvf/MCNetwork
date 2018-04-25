//
//  MCDownloadAdvancedViewController.m
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/16.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import "MCDownloadAdvancedViewController.h"
#import "DownloadRequest.h"
#import "MCDownloadCell.h"
#import "MCDownloadModel.h"

@import MCNetwork;

@interface MCDownloadAdvancedViewController () <UITableViewDelegate, UITableViewDataSource, MCDownloadCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnAllStart;
@property (weak, nonatomic) IBOutlet UIButton *btnAllCancel;
@property (nonatomic, strong) NSMutableArray<MCDownloadModel *> *requests;
@property (nonatomic, strong) NSArray *videoUrls;

@end

@implementation MCDownloadAdvancedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"批量下载";
    self.btnAllStart.enabled = YES;
    self.btnAllCancel.enabled = NO;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/videos"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    if (![fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error]) {
        exit(1);
    }
    
    _videoUrls = @[@"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2947/recorder20171119194729.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2950/recorder20171119190732.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2963/recorder20171119171631.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2963/recorder20171119164241.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2990/recorder20171119162854.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2990/recorder20171119161709.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2990/recorder20171119160049.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2948/recorder20171119152427.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2956/recorder20171119144853.mp4",
                           @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2959/recorder20171119114822.mp4"];
    
    self.requests = [NSMutableArray array];
    for (int i = 0; i < _videoUrls.count; i ++) {
        DownloadRequest *request = [[DownloadRequest alloc] initWithDownloadUrl:_videoUrls[i]];
        request.advanced = YES;
        
        MCDownloadModel *model = [MCDownloadModel new];
        model.request = request;
        model.state = DownloadTaskStateCancel;
        model.name = [[NSURL URLWithString:_videoUrls[i]] lastPathComponent];
        
        [self.requests addObject:model];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MCDownloadCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
    [self allCancel:nil];
}

- (IBAction)allStart:(id)sender {
    self.btnAllStart.enabled = NO;
    self.btnAllCancel.enabled = YES;
    
    for (int i = 0; i < self.requests.count; i ++) {
        MCDownloadModel *model = self.requests[i];
        
        if (model.state != DownloadTaskStateCancel) {
            continue;
        }
        
        NSLog(@"Start +++++++   %d", i);
        
        [self startDownload:model];
    }
    [self.tableView reloadData];
}
- (IBAction)allCancel:(id)sender {
    self.btnAllStart.enabled = YES;
    self.btnAllCancel.enabled = NO;
    
    for (int i = 0; i < self.requests.count; i ++) {
        MCDownloadModel *model = self.requests[i];
        
        if (model.state != DownloadTaskStateRuning) {
            continue;
        }
        
        NSLog(@"Cancel +++++++   %d", i);
        
        [self cancelDownload:model];
    }
    [self.tableView reloadData];
}

#pragma mark - Cancel Or Start

- (void)startDownload:(MCDownloadModel *)model {
    __weak typeof(MCDownloadModel *) weakModel = model;
    __weak typeof(self) weakSelf = self;
    [model.request startWithDownloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        weakModel.progress = downloadProgress.fractionCompleted;
        
        NSArray<UITableViewCell *> *visibleCells = [weakSelf.tableView visibleCells];
        MCDownloadCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[weakSelf indexPathForDownloadModel:weakModel]];
        if ([visibleCells containsObject:cell]) {
            cell.progressView.progress = weakModel.progress;
            cell.progressLab.text = [NSString stringWithFormat:@"%.2f%%",weakModel.progress * 100];
        }
    } success:^(__kindof MCBaseRequest * _Nonnull request) {
        weakModel.state = DownloadTaskStateComplete;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[weakSelf indexPathForDownloadModel:weakModel]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(__kindof MCBaseRequest * _Nonnull request) {
        weakModel.state = DownloadTaskStateCancel;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[weakSelf indexPathForDownloadModel:weakModel]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    model.state = DownloadTaskStateRuning;
}

- (void)cancelDownload:(MCDownloadModel *)model {
    [model.request stop];
    
    model.state = DownloadTaskStateCancel;
}

- (NSIndexPath *)indexPathForDownloadModel:(MCDownloadModel *)model {
    __block NSIndexPath *indexPath = nil;
    [self.requests enumerateObjectsUsingBlock:^(MCDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model isEqual:obj]) {
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            * stop = YES;
        }
    }];
    return indexPath;
}

#pragma mark - MCDownloadCellDelegate

- (void)onCell:(MCDownloadCell *)cell didClickedButtonStartDownloadAction:(UIButton *)sender {
    [self startDownload:cell.model];
    
    [cell setModel:cell.model];
}

- (void)onCell:(MCDownloadCell *)cell didClickedButtonCancelDownloadAction:(UIButton *)sender {
    [self cancelDownload:cell.model];
    
    [cell setModel:cell.model];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.delegate = self;
    cell.model = self.requests[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

@end
