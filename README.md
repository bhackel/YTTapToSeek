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

I looked around on the Apple documentation and found that there is something called an `action` method that is called whenever the gesture is recognized. I read on the Jailbreak discord that this can be found in an IVar called `_targets`, but no such IVar exists for me. However, in the description field of the gesture recognizer, I found that the `action` variable is set to `didPressScrubber` and it has some other attribute called `target` set to `YTInlinePlayerBarContainerView`. I then found this view and the `didPressScrubber` method within it. This was my target to hook.

Now that I am hooking the `YTInlinePlayerBarContainerView`, I did not know how to call the `seekToTime` method in the YTPlayerViewController class. However, after looking at a few open-source tweaks, I found PoomSmart's YouQuality tweak and how it is able to access the `YTMainAppVideoPlayerOverlayViewController` class, which is not the same but will hopefully get me there. [Code here](https://github.com/PoomSmart/YouQuality/blob/a853ceee99e6b9c13d7a68e5cb7e4a02ee3da3d2/Tweak.x#L148-L155)

```objc
%hook YTInlinePlayerBarContainerView
...
%new(v@:@)
- (void)didPressYouQuality:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self.delegate valueForKey:@"_delegate"];
    [c didPressVideoQuality:arg];
    [self updateYouQualityButton:nil];
}
%end
```

From this code, I understood that I needed to look in the instance variables to essentially walk through the inheritance structure to get to the controller that I wanted. We can see that this code snippet first accesses the `self.delegate` property, then accesses the `_delegate` ivar of that object.
It seems like when I want to access a "property", then I should use the dot notation, and when I want to use an "IVar", then I should use the `valueForKey` notation.

The target controller with the `seekToTime` method is in the `YTPlayerViewController` class. I found that the `YTMainAppVideoPlayerOverlayViewController` class has a `@property UIViewController *parentViewController` instance variable that contains the `YTPlayerViewController` that I want, so following that path should work.~~



~~Recall that I also needed the `YTInlinePlayerBarContainerView` class to get the `scrubRangeForScrubX` method. This is easily accessible from the `YTInlineScrubGestureView` through the `@property UIView *superview` instance variable.~~ This is now available in the class that I am hooking.

#### Crashes

I figured out why my code was crashing even though my hooked method makes no changes. Turns out that there's a change introduced in newer Youtube versions that crashes the settings menu that I was using. I referred to YTHoldForSpeed for this knowledge [here](https://github.com/joshuaseltzer/YTHoldForSpeed/commit/e4adb6b0cde87449c9f5bfe285719e0f0ecdfa91). I decided to remove the settings at this point since i plan on integrating it directly into uYouEnhanced

#### More Notes

I found out that the difference between square bracket notation and dot notation is that square bracket notation is handled
at runtime, whereas dot notation is handled at compile time. To minimize bugs, I will try to switch it over to use dot
notation. This means that I will need to have interfaces for every class that I am interacting with so that the
methods and properties are defined at compile-time.

Just kidding that isn't true. Turns out that dot notation vs bracket notation is quite strange. It seems that for accessing properties, it is advised to use dot notation for clarity. However, when calling any methods, it's required to use square bracket notation.

For example:
```
[gestureRecognizer locationInView:self];
```
This line calls the `locationInView` method of the `gestureRecognizer` variable with 1 unnamed parameter called self.

```
YTMainAppVideoPlayerOverlayViewController *mainAppController = [self.delegate valueForKey:@"_delegate"];
```
This line creates a variable of name mainAppController of type `YTMainAppVideoPlayerOverlayViewController*`. It first accesses the `delegate` property of `self`, then it calls the `valueForKey` method on that object with the parameter `@"_delegate"`.

#### Stuff
This is a note from a bit later in development. I found out that the general idea is to use keyForValue for any IVar, and to use dot notation with @interface with @property declarations for any @property variable. 
