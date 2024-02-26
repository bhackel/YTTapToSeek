#import <sys/utsname.h>
#import <rootless.h>
#import "YTTapToSeek.h"


void YTTTS_showSnackBar(NSString *text);
NSBundle *YTTTS_getTweakBundle();


%group YTTTS_Tweak
    // TODO
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
