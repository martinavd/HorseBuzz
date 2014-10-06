//
//  WEPopoverContentViewController.m
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContentViewController.h"


#define ERAS_DEMI @"Eras Demi ITC"

@implementation WEPopoverContentViewController
@synthesize interestArray;
@synthesize delegate;
@synthesize selectedIndexArray;
@synthesize interestTable;
#pragma mark -
#pragma mark Initialization

/*- (id)initWithStyle:(UITableViewStyle)style AnddataArray:(NSMutableArray *)response {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
         dataArray =[[NSMutableArray alloc]init];
        self.dataArray = response ;
		self.contentSizeForViewInPopover = CGSizeMake(150,100);
        
    }
    return self;
}
*/
-(id)initwithArray:(NSMutableArray *)dataArrays{
    
    if ((self = [super init])) {
        interestArray =[[NSMutableArray alloc]init];
        selectedIndexArray=[[NSMutableArray alloc]init];
        
       NSArray *selectedInterestArrays = [[NSUserDefaults standardUserDefaults]objectForKey:@"selectedInterestArrays"];
    
        if (selectedInterestArrays.count > 0) {
            [selectedIndexArray addObjectsFromArray:selectedInterestArrays];
        }
        
        self.interestArray = dataArrays;
		self.contentSizeForViewInPopover = CGSizeMake(150,100);
        
    }
    return self;
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
   
    int width=(interestArray.count >6 ) ? 6 :  interestArray.count;
    self.contentSizeForViewInPopover = CGSizeMake(222,width*35.0);
    [super viewDidLoad];
  
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithTitle:@"Search People" style:UIBarButtonItemStyleBordered target:self action:@selector(closePopOver)];

    UIBarButtonItem *fS=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIToolbar *tollBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,220,35)];
    
    NSArray *Array=[NSArray  arrayWithObjects:fS,barButton, nil];
    [tollBar setItems:Array];
    [self.view addSubview:tollBar];
    
    
    interestTable=[[UITableView alloc]initWithFrame:CGRectMake(0,35,220, (width*35.0)-35) style:UITableViewStylePlain];
    interestTable.delegate=self;
    interestTable.dataSource=self;
    
	interestTable.rowHeight = 35.0;
    [self.view addSubview:interestTable];
   
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)closePopOver{
    [self.delegate selectioDidFinishWithInterest:selectedIndexArray];
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(Cell==nil){
        Cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    Cell.textLabel.text=[interestArray objectAtIndex:indexPath.row];
    Cell.accessoryType = UITableViewCellAccessoryNone;
    for(int i=0;i<selectedIndexArray.count;i++){
        if([[selectedIndexArray objectAtIndex:i] isEqualToString:[NSString stringWithFormat:@"%i",indexPath.row]]){
                        
            Cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
    }
    
    
    return Cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return interestArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if((indexPath.row==0) && (selectedIndexArray.count ==interestArray.count)){
        [selectedIndexArray removeAllObjects];
    }
    else if(indexPath.row==0){
        [selectedIndexArray removeAllObjects];
        for(int i=0;i<interestArray.count;i++){
            [selectedIndexArray addObject:[NSString stringWithFormat:@"%i",i]];
        }
        
    }
    else{
        BOOL checkPrevious=FALSE;
        for(int i=0;i<selectedIndexArray.count;i++){
            
            if([[selectedIndexArray objectAtIndex:i] isEqualToString:[NSString stringWithFormat:@"%i",indexPath.row]]){
                [selectedIndexArray removeObjectAtIndex:i];
                checkPrevious=TRUE;
                for(int j=0;j<selectedIndexArray.count;j++){
                    if([[selectedIndexArray objectAtIndex:j]isEqualToString:@"0"]){
                        [selectedIndexArray removeObject:@"0"];
                        break;
                    }
                }
                
                break;
            }
        }
        
        if(!checkPrevious){
            [selectedIndexArray addObject:[NSString stringWithFormat:@"%i",indexPath.row]];
            if(selectedIndexArray.count ==interestArray.count-1){
                [selectedIndexArray addObject:@"0"];
            }
            
            
            
        }
    }
    
    
    [interestTable reloadData];
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