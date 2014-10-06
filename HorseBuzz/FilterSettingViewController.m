//
//  FilterSettingViewController.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "FilterSettingViewController.h"
#import "InterestKeys.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
#import "MBProgressHUD.h"
#import "SetInvisibleUser.h"
#import "GAI.h"

@interface FilterSettingViewController (){
    NSMutableArray *interestArray;
    NSMutableArray *selectedIndexArray;
    MBProgressHUD *mbProgressHUD;
    BOOL checkFirstTime;
    UIButton *eyeButton;
}

@end

@implementation FilterSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Filter view"];
    [tracker set:@"ScreenName" value: @"Horse Buzz - Filter view"];
    // google tracking code end
    
    self.title=@"Update Interest";
    
    
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,85, 20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@" Settings" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    
    interestArray=[[NSMutableArray alloc]init];
    [interestArray addObjectsFromArray:[InterestKeys sharedInstance].interestArray];
    
    selectedIndexArray=[[NSMutableArray alloc]init];
    [super viewDidLoad];
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        checkFirstTime=TRUE;
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        ;
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        
        
        [mbProgressHUD show:YES];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:PROFILEDETAILS requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
}

-(void)setVisibilty{
    SetInvisibleUser *setVisible =[[SetInvisibleUser alloc]init];
    [setVisible setVisibilty];
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)subMitInterest:(id)sender{
    if(selectedIndexArray.count!=0){
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            checkFirstTime=FALSE;
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            ;
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            if([selectedIndexArray containsObject:@"0"]){
                [selectedIndexArray removeObject:@"0"];
            }
            NSString *selInterest=@"";
            for(int i=0;i<selectedIndexArray.count;i++){
                selInterest=[selInterest stringByAppendingString:[NSString stringWithFormat:@"%@,",[[InterestKeys sharedInstance].interestIDArray objectAtIndex:[[selectedIndexArray objectAtIndex:i]intValue]]]];
            }
            selInterest = [selInterest substringToIndex:[selInterest length] - 1];
            [dictionary setObject:selInterest forKey:@"area_intrest"];
            [mbProgressHUD show:YES];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:UPDATEDINTEREST requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Please select atleast one interest" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void)getResponsedata:(NSDictionary *)data{
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    
    if (status) {
        if(checkFirstTime){
            checkFirstTime=FALSE;
            NSMutableDictionary *profileDetailArray=[[NSMutableDictionary alloc]initWithDictionary:data];
            NSMutableArray *interestarray=[NSMutableArray arrayWithArray:[[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"area_intrest"] componentsSeparatedByString:@","]];
            
            for(int i=0;i<interestarray.count;i++){
                int selIndex =[[InterestKeys sharedInstance].interestIDArray indexOfObject:[interestarray objectAtIndex:i]];
                [selectedIndexArray addObject:[NSString stringWithFormat:@"%i",selIndex]];
                if(selectedIndexArray.count ==interestArray.count-1){
                    [selectedIndexArray addObject:@"0"];
                }
                [interestTable reloadData];
                
            }
        }
        else{
            UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your interest has been updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            Alert.tag=110;
            [Alert show];
        }
    }
}

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
