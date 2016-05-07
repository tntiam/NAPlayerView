//
//  NAPlayerView.h
//  ConvertSwiftToObjectiveC
//
//  Created by Tran Trong Nghia on 5/7/16.
//  Copyright © 2016 Tran Trong Nghia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>

typedef void (^NAProgressPlayerView)(CGFloat progress);

@class NAPlayerView;

@protocol NAPlayerViewDelegate <NSObject>
@optional
- (void)playerViewDidFinish:(NAPlayerView *)playerView;
@end

@interface NAPlayerView : UIView
@property (weak  , nonatomic) id<NAPlayerViewDelegate>delegate;
@property (copy  , nonatomic) NAProgressPlayerView progress;
@property (strong, nonatomic) NSURL *videoURL;
@property (assign, nonatomic, readonly) BOOL isPlaying;
@property (assign, nonatomic) CMTime seekTime;

- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;
@end
