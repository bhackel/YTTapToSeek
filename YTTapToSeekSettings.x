#import "YTTapToSeek.h"

// Adapted from 
// https://github.com/therealFoxster/DontEatMyContent/blob/0f9a8c991bd8a60f5a6f3f39061dac86cf361131/Settings.x
// Thanks to therealFoxster, PoomSmart, qnblackcat

extern void YTTTS_showSnackBar(NSString *text);
extern NSBundle *YTTTS_getTweakBundle();

static const NSInteger sectionId = 343; // YTTapToSeek's section ID (just a random number)


// Category for additional functions
@interface YTSettingsSectionItemManager (_YTTTS)
- (void)updateYTTTSSectionWithEntry:(id)entry;
@end


%group YTTTS_Settings

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)]; // Index of Settings > General
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(sectionId) atIndex:insertIndex + 1]; // Insert YTTapToSeek settings under General
    return mutableOrder;
}
%end

%hook YTSettingsSectionItemManager
%new
- (void)updateYTTTSSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSMutableArray *sectionItems = [NSMutableArray array]; // Create autoreleased array
    NSBundle *bundle = YTTTS_getTweakBundle();

    // Enabled
    YTSettingsSectionItem *enabled = [%c(YTSettingsSectionItem)
        switchItemWithTitle:LOCALIZED_STRING(@"ENABLED")
        titleDescription:LOCALIZED_STRING(@"TWEAK_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_TWEAK_ENABLED
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:ENABLED_KEY];
            
            YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
            [settingsViewController.navigationController popViewControllerAnimated:YES];
            YTTTS_showSnackBar(LOCALIZED_STRING(@"CHANGES_SAVED"));
            return YES;
        }
        settingItemId:0
    ];
    [sectionItems addObject:enabled];

    // Report an issue
    YTSettingsSectionItem *reportIssue = [%c(YTSettingsSectionItem)
        itemWithTitle:LOCALIZED_STRING(@"REPORT_ISSUE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            NSString *url = [NSString stringWithFormat:@"https://github.com/bhackel/YTTapToSeek/issues/new/?title=[v%@] %@", VERSION, LOCALIZED_STRING(@"ADD_TITLE")];
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
        }
    ];
    [sectionItems addObject:reportIssue];

    // Version
    YTSettingsSectionItem *version = [%c(YTSettingsSectionItem)
        itemWithTitle:LOCALIZED_STRING(@"VERSION")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return VERSION;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/bhackel/YTTapToSeek"]];
        }
    ];
    [sectionItems addObject:version];

    [delegate setSectionItems:sectionItems 
        forCategory:sectionId 
        title:YTTTS
        titleDescription:nil 
        headerHidden:NO
    ];
}
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == sectionId) {
        [self updateYTTTSSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end

%end // group YTTTS_Settings


%ctor {
    %init(YTTTS_Settings);
}