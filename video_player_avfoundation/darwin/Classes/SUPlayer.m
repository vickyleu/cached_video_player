//
//  SUPlayer.m
//  SULoader
//
//  Created by 万众科技 on 16/6/24.
//  Copyright © 2016年 万众科技. All rights reserved.
//

#import "SUPlayer.h"

@interface SUPlayer ()

@property (nonatomic, strong) NSURL * url;
@property (nonatomic, strong) AVPlayerItem * item;
@property (nonatomic, assign) BOOL  isItemType;

@property (nonatomic, strong) AVPlayerItem * currentItem;
@property (nonatomic, strong) SUResourceLoader * resourceLoader;

@property (nonatomic, strong) id timeObserve;

@property (nonatomic, strong) AVPlayer * myplayer;

@end


@implementation SUPlayer



- (instancetype)initWithItem:(AVPlayerItem *)item {
    if (self == [super init]) {
        self.item = item;
        self.isItemType= YES;
        [self reloadCurrentItem];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self == [super init]) {
        self.url = url;
        self.isItemType= NO;
        [self reloadCurrentItem];
    }
    return self;
}


-(AVPlayer*)player{
    return self.myplayer;
}

- (void)videoDownloaded:(NSURL*)videoUrl withLocalFile:(NSString*)cacheFilePath  completionHandler:(void (^)(BOOL))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 获取文件属性
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:cacheFilePath error:&attributesError];
        if (attributesError) {
            NSLog(@"Error getting file attributes: %@", attributesError);
            completionHandler(NO);
            return;
        }
        // 获取文件大小
        NSNumber *fileSize = fileAttributes[NSFileSize];
        __block NSNumber *expectedFileSize = nil;
        AVURLAsset* urlAsset = [AVURLAsset assetWithURL:videoUrl];
        
        [urlAsset loadValuesAsynchronouslyForKeys:@[NSURLFileSizeKey] completionHandler:^{
            NSError *error = nil;
            NSNumber *fileSizeLoaded = nil;
            AVKeyValueStatus status = [videoUrl getResourceValue:&fileSizeLoaded forKey:NSURLFileSizeKey error:&error];
            if (status == AVKeyValueStatusLoaded) {
                expectedFileSize = fileSizeLoaded;
            } else {
                NSLog(@"Error loading file size: %@", error);
            }
            if (expectedFileSize!=nil && fileSize && fileSize.unsignedIntegerValue >= expectedFileSize.unsignedIntValue) {
                NSLog(@"下载完成");
                completionHandler(YES);
            } else {
                NSLog(@"文件未完成下载");
                completionHandler(NO);
            }
        }];

   });
}

- (void)reloadCurrentItem {
    //没有缓存播放网络文件
    if(!self.resourceLoader){
        self.resourceLoader = [[SUResourceLoader alloc]init];
        self.resourceLoader.delegate = self;
    }
    //Item
    if(self.isItemType){
        AVURLAsset* urlAsset = (AVURLAsset*)self.item.asset;
        if ([[urlAsset.URL originalSchemeURL].absoluteString hasPrefix:@"http"]) {
            //有缓存播放缓存文件
            NSString * cacheFilePath = [SUFileHandle cacheFileExistsWithURL:[urlAsset.URL originalSchemeURL]];
            if (cacheFilePath) {
                
                [self videoDownloaded:[urlAsset.URL originalSchemeURL] withLocalFile:cacheFilePath completionHandler:^(BOOL isDownloaded) {
                            if (isDownloaded) {
                                AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:cacheFilePath] options:nil];
                                self.currentItem = [AVPlayerItem playerItemWithAsset:movieAsset];
                                NSLog(@"有缓存，播放缓存文件 item %@  Asset:%@",cacheFilePath,movieAsset);
                            } else {
                                [urlAsset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
                                self.currentItem = [AVPlayerItem playerItemWithAsset:urlAsset];
                                NSLog(@"无缓存，播放网络文件 url ");
                            }
                            // Player
                            if (self.myplayer) {
                                [self.myplayer replaceCurrentItemWithPlayerItem:self.currentItem];
                            } else {
                                self.myplayer = [AVPlayer playerWithPlayerItem:self.currentItem];
                            }
                }];
                return;
            }else {
                [urlAsset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
                self.currentItem = self.item;
                NSLog(@"无缓存，播放网络文件 item3");
            }
        }else {
            self.currentItem = self.item;
            NSLog(@"播放本地文件 item");
        }
        //Player
        if(self.myplayer){
            [self.myplayer replaceCurrentItemWithPlayerItem:self.currentItem];
        }else{
            self.myplayer = [AVPlayer playerWithPlayerItem:self.currentItem];
        }
    }else{
        if ([self.url.absoluteString hasPrefix:@"http"]) {
            //有缓存播放缓存文件
            NSString * cacheFilePath = [SUFileHandle cacheFileExistsWithURL:self.url];
            AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[self.url specialSchemeURL] options:nil];
            if (cacheFilePath) {
                [self videoDownloaded:self.url withLocalFile:cacheFilePath completionHandler:^(BOOL isDownloaded) {
                    if(isDownloaded){
                        NSURL * url = [NSURL fileURLWithPath:cacheFilePath];
                        AVPlayerItem* itemTemp=[AVPlayerItem playerItemWithURL:url];
                        self.currentItem =itemTemp;
                        NSLog(@"有缓存，播放缓存文件 item %@  Asset:%@",cacheFilePath,asset);
                    }else{
                        [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
                        self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
                        NSLog(@"无缓存，播放网络文件 url ");
                    }
                    // Player
                    if (self.myplayer) {
                        [self.myplayer replaceCurrentItemWithPlayerItem:self.currentItem];
                    } else {
                        self.myplayer = [AVPlayer playerWithPlayerItem:self.currentItem];
                    }
                }];
                return;
            }else {
                [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
                self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
                NSLog(@"无缓存，播放网络文件 url ");
            }
        }else {
            self.currentItem = [AVPlayerItem playerItemWithURL:self.url];
            NSLog(@"播放本地文件 url ");
           
        }
        //Player
        if(self.myplayer){
            [self.myplayer replaceCurrentItemWithPlayerItem:self.currentItem];
        }else{
            self.myplayer = [AVPlayer playerWithPlayerItem:self.currentItem];
            
        }
    }
    
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];

    //Observer
    [self addObserver];
    //State
    _state = SUPlayerStateWaiting;
}



- (void)replaceItemWithURL:(NSURL *)url {
    if (!self.isItemType) {
        self.url = url;
        [self reloadCurrentItem];
    }
}


- (void)replaceItemWithItem:(AVPlayerItem *)item {
    if (self.isItemType) {
        self.item = item;
        [self reloadCurrentItem];
    }
}


- (void)play {
    if (self.state == SUPlayerStatePaused || self.state == SUPlayerStateWaiting) {
        [self.player play];
    }
}


- (void)pause {
    if (self.state == SUPlayerStatePlaying) {
        [self.player pause];
    }
}

- (BOOL)isPlaying{
    if (self.state == SUPlayerStatePlaying) {
        return YES;
    }
    return NO;
}

- (void)stop {
    if (self.state == SUPlayerStateStopped) {
        return;
    }
    [self.player pause];
    [self.resourceLoader stopLoading];
    [self removeObserver];
    self.resourceLoader = nil;
    self.currentItem = nil;
    self.myplayer = nil;
    self.progress = 0.0;
    self.duration = 0.0;
    self.state = SUPlayerStateStopped;
}
- (void)seekToTime:(CMTime)seconds toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^)(BOOL finished))completionHandler{
    if (self.state == SUPlayerStatePlaying || self.state == SUPlayerStatePaused) {
        // 暂停后滑动slider后    暂停播放状态
        // 播放中后滑动slider后   自动播放状态
//        [self.player pause];
        self.resourceLoader.seekRequired = YES;
        [self.player seekToTime:seconds toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
            completionHandler(finished);
            NSLog(@"seekComplete!!");
            if ([self isPlaying]) {
                [self.player play];
            }
            
        }];
//        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
//            NSLog(@"seekComplete!!");
//            if ([self isPlaying]) {
//                [self.player play];
//            }
//        }];;
    }
}
- (void)seekToTime:(CGFloat)seconds {
    if (self.state == SUPlayerStatePlaying || self.state == SUPlayerStatePaused) {
        // 暂停后滑动slider后    暂停播放状态
        // 播放中后滑动slider后   自动播放状态
//        [self.player pause];
        self.resourceLoader.seekRequired = YES;
        [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            NSLog(@"seekComplete!!");
            if ([self isPlaying]) {
                [self.player play];
            }
        }];;
    }
}

#pragma mark - NSNotification 打断处理

- (void)audioSessionInterrupted:(NSNotification *)notification{
    //通知类型
    NSDictionary * info = notification.userInfo;
    // AVAudioSessionInterruptionTypeBegan ==
    if ([[info objectForKey:AVAudioSessionInterruptionTypeKey] integerValue] == 1) {
        [self.player pause];
    }else{
        [self.player play];
    }
}


#pragma mark - KVO
- (void)addObserver {
    AVPlayerItem * songItem = self.currentItem;
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];
    //播放进度
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat current = CMTimeGetSeconds(time);
        CGFloat total = CMTimeGetSeconds(songItem.duration);
        weakSelf.duration = total;
        weakSelf.progress = current / total;
    }];
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [songItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver {
    AVPlayerItem * songItem = self.currentItem;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    [songItem removeObserver:self forKeyPath:@"status"];
    [songItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [songItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [songItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

/**
 *  通过KVO监控播放器状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem * songItem = object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        NSLog(@"共缓冲%.2f",totalBuffer);
    }
    if ([keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0.0) {
            _state = SUPlayerStatePaused;
        }else {
            _state = SUPlayerStatePlaying;
        }
    }
}

- (void)playbackFinished {
    NSLog(@"播放完成");
    [self stop];
}

#pragma mark - SULoaderDelegate
- (void)loader:(SUResourceLoader *)loader cacheProgress:(CGFloat)progress {
    self.cacheProgress = progress;
}

#pragma mark - Property Set
- (void)setProgress:(CGFloat)progress {
    [self willChangeValueForKey:@"progress"];
    _progress = progress;
    [self didChangeValueForKey:@"progress"];
}

- (void)setState:(SUPlayerState)state {
    [self willChangeValueForKey:@"progress"];
    _state = state;
    [self didChangeValueForKey:@"progress"];
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    [self willChangeValueForKey:@"progress"];
    _cacheProgress = cacheProgress;
    [self didChangeValueForKey:@"progress"];
}

- (void)setDuration:(CGFloat)duration {
    if (duration != _duration && !isnan(duration)) {
        [self willChangeValueForKey:@"duration"];
        NSLog(@"duration %f",duration);
        _duration = duration;
        [self didChangeValueForKey:@"duration"];
    }
}

#pragma mark - CacheFile
- (BOOL)currentItemCacheState {
    if ([self.url.absoluteString hasPrefix:@"http"]) {
        if (self.resourceLoader) {
            return self.resourceLoader.cacheFinished;
        }
        return YES;
    }
    return NO;
}

- (NSString *)currentItemCacheFilePath {
    if (![self currentItemCacheState]) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:self.url]];;
}

+ (BOOL)clearCache {
    [SUFileHandle clearCache];
    return YES;
}


@end
