# YTTapToSeek
iOS tweak for Youtube to add single tap to jump anywhere in a video


## Development notes

#### First few hours
To make this, I want to add a listener to the seek bar that detects the tap position.
Then using this position, I want to use some method to jump to that part in the video.

Current researched ideas using FLEX (Youtube 19.06.2):

`YTInlineScrubGestureView` is the seek bar. It has something called `*_gestureRecognizers`, which is an array of 3 gesture recognizer objects. One of these is a `UITapGestureRecognizer`. After a short test of randomly tapping in the seek bar, I found that there is a `location` attribute for this object that can be obtained by calling the `- (CGPoint)location` method. This method seems to return a pixel coordinate in something called an `NSPoint` object.

For changing the time, we can refer to iSponsorBlock's code to figure out how it jumps. It hooks `YTPlayerViewController` and calls the `- (void)seekToTime:(CGFloat)` method to change the time in the video. This method takes in a float that represents the amount of time that has passed in the video.

Next I needed to figure out how to translate the tap location into a timestamp. I wondered if the tap location in UITapGestureRecognizer was relative to the screen or relative to the view. I went into landscape and experimented. I noticed that the position did seem to be relative to the view, but also that the view in Landscape was longer than the actual timebar, meaning that I would need to look for a different way to get the timestamp.

I started looking around for a method that would do the conversion for me since that seemed more reasonable. I eventually found `- (CGFloat)scrubRangeForScrubX:(CGFloat)` in the `YTInlinePlayerBarContainerView` class. What it appears to do is convert the X coordinate in the timebar view to a float from 0 to 1. I realized that I could use this float and multiply it by the total video time stored in `CGFloat _totalTime` or using the `YTMainAppVideoPlayerOverlayViewController` method `- (CGFloat)totalTime`

#### Next steps
I need to find a way to run some custom method whenever there is an update to `UITapGestureRecognizer`