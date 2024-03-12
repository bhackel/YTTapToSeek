#import <UIKit/UIKit.h>

#define YTTTS @"YTTapToSeek"
#define VERSION @"1.0"

// Keys
#define ENABLED_KEY @"YTTTS_enabled"

#define IS_TWEAK_ENABLED [[NSUserDefaults standardUserDefaults] boolForKey:ENABLED_KEY]
#define LOCALIZED_STRING(s) [bundle localizedStringForKey:s value:nil table:nil]


// YTTapToSeek Headers
// TODO


// Youtube Settings
@interface YTSettingsCell : UICollectionViewCell
@end

@interface YTSettingsSectionItemManager : NSObject
- (id)parentResponder;
@end

@interface YTSettingsSectionItem : NSObject
+ (instancetype)switchItemWithTitle:(NSString *)title
    titleDescription:(NSString *)titleDescription
    accessibilityIdentifier:(NSString *)accessibilityIdentifier
    switchOn:(BOOL)switchOn
    switchBlock:(BOOL (^)(YTSettingsCell *, BOOL))switchBlock
    settingItemId:(int)settingItemId;
+ (instancetype)itemWithTitle:(NSString *)title
    titleDescription:(NSString *)titleDescription
    accessibilityIdentifier:(NSString *)accessibilityIdentifier
    detailTextBlock:(id)detailTextBlock
    selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock;
@end

@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems
    forCategory:(NSInteger)category
    title:(NSString *)title
    titleDescription:(NSString *)titleDescription
    headerHidden:(BOOL)headerHidden;
@end


// Snack bar popup
@interface YTHUDMessage : NSObject
+ (id)messageWithText:(id)text;
@end
@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(id)message;
+ (id)sharedInstance;
@end

@interface YTUIUtils : NSObject
+ (BOOL)openURL:(NSURL *)url;
@end