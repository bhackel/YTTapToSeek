#import <sys/utsname.h>
#import <rootless.h>
#import "YTTapToSeek.h"


%group YTTTS_Tweak
    %hook YTInlinePlayerBarContainerView
        - (void)didPressScrubber:(id)arg1 {
            %orig;
            // Get access to the seekToTime method
            YTMainAppVideoPlayerOverlayViewController *mainAppController = [self.delegate valueForKey:@"_delegate"];
            if (mainAppController == nil)
                return;
            YTPlayerViewController *playerViewController = [mainAppController valueForKey:@"parentViewController"];
            // Get the X position of this tap from arg1
            UIGestureRecognizer *gestureRecognizer = (UIGestureRecognizer *)arg1;
            CGPoint location = [gestureRecognizer locationInView:self];
            CGFloat x = location.x;
            // Get the associated proportion of time using scrubRangeForScrubX
            double timestampFraction = [self scrubRangeForScrubX:x];
            // Get the timestamp from the fraction
            double timestamp = [mainAppController totalTime] * timestampFraction;
            // Jump to the timestamp
            [playerViewController seekToTime:timestamp];
        }
    %end
%end

%ctor {
    %init(YTTTS_Tweak);
}

