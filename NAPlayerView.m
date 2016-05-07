//
//  NAPlayerView.m
//  ConvertSwiftToObjectiveC
//
//  Created by Tran Trong Nghia on 5/7/16.
//  Copyright © 2016 Tran Trong Nghia. All rights reserved.
//

#import "NAPlayerView.h"

@interface NAPlayerView() {
    NSURL *_videoURL;
    BOOL _isPlaying;
    CMTime _seekTime;
    BOOL isFinish;
}
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@end

@implementation NAPlayerView
@synthesize videoURL = _videoURL;
@synthesize isPlaying = _isPlaying;
@synthesize seekTime = _seekTime;

#pragma mark - INIT
- (void)dealloc {
    [self unregisterNotification];
}

- (void)awakeFromNib {
    [self registerNotification];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)createVideo {
    [_playerLayer removeFromSuperlayer];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    _player = [AVPlayer playerWithURL:self.videoURL];
    _player.volume = 1.0;
    [_player replaceCurrentItemWithPlayerItem:playerItem];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _playerLayer.frame = self.bounds;
    [self.layer addSublayer:_playerLayer];
    
    [self createObserver];
}

- (void)createObserver {
    CGFloat interval = 1.0 / 60.0;
    CMTime playerDuration = [self playItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    
    /*
    CGFloat duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        CGFloat width = (CGFloat)CGRectGetWidth(self.progressView.bounds);
        interval = (interval * duration / width);
    }
     */
    
    __block NAPlayerView *this = self;
    CMTime timeObserverForInternal = CMTimeMakeWithSeconds(interval, INT32_C(NSEC_PER_SEC));
    [self.player addPeriodicTimeObserverForInterval:timeObserverForInternal queue:nil usingBlock:^(CMTime time) {
        [this syncProgress];
    }];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

#pragma mark - PROPERTY
- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    [self createVideo];
}

- (BOOL)isPlaying {
    _isPlaying = (self.player.rate == 1.0);
    return _isPlaying;
}

- (void)setSeekTime:(CMTime)seekTime {
    _seekTime = seekTime;
    [self.player seekToTime:_seekTime];
}

- (CMTime)seekTime {
    _seekTime = self.player.currentTime;
    return _seekTime;
}

#pragma mark - PRIVATE METHOD
- (void)playDidFinish:(NSNotification *)notification {
    isFinish = YES;
    if ([self.delegate respondsToSelector:@selector(playerViewDidFinish:)]) {
        [self.delegate playerViewDidFinish:self];
    }
}

- (CMTime)playItemDuration {
    if (self.player) {
        AVPlayerItem *playerItem = self.player.currentItem;
        return playerItem.duration;
    }
    
    /*
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return playerItem.duration;
    }
     */
    
    return kCMTimeInvalid;
}

- (void)syncProgress {    
    CMTime playerDuration = [self playItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        if (self.progress) {
            self.progress(0.0);
        }
        return;
    }
    
    CGFloat duration = (CGFloat)CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        CGFloat time = (CGFloat)CMTimeGetSeconds(self.player.currentTime);
        CGFloat value = time / duration;
        if (self.progress) {
            self.progress(value);
        }
    }
}

#pragma mark - PUBLISH METHOD
- (void)playVideo {
    if (!self.player) {
        self.videoURL = _videoURL;
    }
    if (isFinish) {
        self.seekTime = kCMTimeZero;
        isFinish = NO;
    }
    [self.player play];
}

- (void)pauseVideo {
    [self.player pause];
}

- (void)stopVideo {
    [self pauseVideo];
    self.player = nil;
}

@end
