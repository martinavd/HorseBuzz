//
//  WEPopoverContentViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WEPopoverContentViewController;
@protocol WEPopoverContentDelegate
-(void)selectioDidFinishWithInterest:(NSArray *)intrestsArray;
@end
@interface WEPopoverContentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
  
    id<WEPopoverContentDelegate>delegate;
}
@property(nonatomic,retain)NSMutableArray *interestArray;
@property(nonatomic,retain)NSMutableArray *selectedIndexArray;
@property(nonatomic,retain)UITableView *interestTable;
@property(nonatomic,retain)id<WEPopoverContentDelegate>delegate;
//- (id)initWithStyle:(UITableViewStyle)style  AnddataArray:(NSMutableArray *)dataArray;
-(id)initwithArray:(NSMutableArray *)dataArray;
@end
