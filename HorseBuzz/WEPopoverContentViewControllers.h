//
//  WEPopoverContentViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WEPopoverContentViewControllers;
@protocol WEPopoverContentDelegates
-(void)selectioDidFinishWithQuanity:(NSString *)consumedQuantity;
@end
@interface WEPopoverContentViewControllers : UITableViewController {
    
    id<WEPopoverContentDelegates>delegate;
}
@property(nonatomic,retain)NSMutableArray *dataArray;;
@property(nonatomic,retain)id<WEPopoverContentDelegates>delegate;
- (id)initWithStyle:(UITableViewStyle)style  AnddataArray:(NSMutableArray *)dataArray;
@end
