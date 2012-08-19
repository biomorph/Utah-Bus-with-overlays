//
//  FavoritesTableViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesTableViewController;
@protocol FavoritesTableViewControllerDelegate <NSObject>

- (void) showFavorite:(NSString *)favorite :(FavoritesTableViewController *)sender;

@end
@interface FavoritesTableViewController : UITableViewController
@property (nonatomic, weak) id <FavoritesTableViewControllerDelegate> delegate;

@end
