#import <sys/utsname.h>
#import <rootless.h>
#import "YTTapToSeek.h"


void YTTTS_showSnackBar(NSString *text);
NSBundle *YTTTS_getTweakBundle();


%group YTTTS_Tweak
    %hook YTInlinePlayerBarContainerView
        - (void)didPressScrubber:(id)arg1 {
            %orig;
            // Apple documentation states to check for ended
            if (sender.state == UIGestureRecognizerStateEnded) {
                // Get access to the seekToTime method
                YTMainAppVideoPlayerOverlayViewController *mainAppController = [self.delegate valueForKey:@"_delegate"];
                YTPlayerViewController *playerViewController = mainAppController.parentViewController;
                // Get the X position of this tap from arg1
                CGFloat x = [arg1 locationInView:arg1.view].x;
                // Get the associated timestamp using scrubRangeForScrubX
                double timestamp = [self scrubRangeForScrubX:x];
                // Jump to the timestamp
                [playerViewController seekToTime:timestamp];
            }
        }
    %end
%end


%ctor {
    %init(YTTTS_Tweak);
}


// Helper methods for tweak settings
void YTTTS_showSnackBar(NSString *text) {
    YTHUDMessage *message = [%c(YTHUDMessage) messageWithText:text];
    GOOHUDManagerInternal *manager = [%c(GOOHUDManagerInternal) sharedInstance];
    [manager showMessageMainThread:message];
}

NSBundle *YTTTS_getTweakBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"YTTapToSeek" ofType:@"bundle"];
        if (bundlePath)
            bundle = [NSBundle bundleWithPath:bundlePath];
        else // Rootless
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YTTapToSeek.bundle")];
    });
    return bundle;
}
