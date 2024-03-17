#import <UIKit/UIKit.h>


// YTTapToSeek Headers
@interface YTInlinePlayerBarContainerView : UIView
@property (nonatomic, weak, readwrite) id delegate;
- (void)didPressScrubber:(id)arg1;
- (CGFloat)scrubRangeForScrubX:(CGFloat)arg1;
@end

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
- (CGFloat)totalTime;
@end

@interface YTPlayerViewController : UIViewController
- (void)seekToTime:(double)time;
@end


