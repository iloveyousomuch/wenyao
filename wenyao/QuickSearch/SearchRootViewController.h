//
//  SearchParentViewController.h
//  wenyao
//
//  Created by Meng on 14-9-20.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"

@protocol SearchRootViewControllerDelegate <NSObject>

- (void)searchBarText:(NSString *)text;

@end
typedef enum {
    SearchParentTableViewHistroySearchTypeMedicine = 0,
    SearchParentTableViewHistroySearchTypeDisease,
    SearchParentTableViewHistroySearchTypeSymptom
}SearchHistroyType;

@interface SearchRootViewController : BaseViewController

@property (nonatomic, assign) BOOL  loadMore;
@property (nonatomic ,strong) UINavigationController * navigation;

@property (nonatomic, strong) UIViewController  *containerViewController;
@property (nonatomic ,assign) SearchHistroyType histroySearchType;
@property (nonatomic ,copy) NSString * keyWord;
@property (nonatomic ,copy) __block void(^scrollBlock)(void);
@property (nonatomic ,weak) id<SearchRootViewControllerDelegate>delegate;

@property (nonatomic ,strong) UISearchBar * searchBar;

- (void)viewDidCurrentView;
@end
