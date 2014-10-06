//
//  WEPopoverContentViewController.m
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContentViewControllers.h"

#define ERAS_DEMI @"Eras Demi ITC"

@implementation WEPopoverContentViewControllers
@synthesize dataArray;
@synthesize delegate;
#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style AnddataArray:(NSMutableArray *)response {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
        dataArray =[[NSMutableArray alloc]init];
        self.dataArray = response ;
		self.contentSizeForViewInPopover = CGSizeMake(250,100);
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   
	self.tableView.rowHeight = 35.0;
    
    self.contentSizeForViewInPopover = CGSizeMake(250,100);
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.dataArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Configure the cell...
	cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
	cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:ERAS_DEMI size:12.0];
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for(int i = 0; i < dataArray.count; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:ip];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    UITableViewCell *cellSelected = [tableView cellForRowAtIndexPath:indexPath];
    [cellSelected setAccessoryType:UITableViewCellAccessoryCheckmark];
	[self.delegate selectioDidFinishWithQuanity:[dataArray objectAtIndex:indexPath.row]];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}





@end

