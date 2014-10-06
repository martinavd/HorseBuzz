//
//  EmotionsViewController.m
//  HorseBuzz
//
//  Created by Welcome on 07/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import "EmotionsViewController.h"

@interface EmotionsViewController ()

@end

@implementation EmotionsViewController
@synthesize messageView;
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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor grayColor]];
    [self loadEmotionsTab1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (void)loadEmotionsTab1{
    
    int X = 10;
    int Y = 10;
    NSString *strEmotions = @"\ue415,\ue404,\ue105,\ue409,\ue40e,\ue402,\ue108,\ue403,\ue058,\ue407,\ue401,\ue40f,\ue40b,\ue406,\ue413,\ue411,\ue412	,\ue410,\ue107,\ue059,\ue416,\ue408,\ue40c,\ue00e,\ue421,\ue420,\ue00d,\ue010,\ue011,\ue41e,\ue012,\ue422,\ue22e,\ue22f,\ue231,\ue230,\ue427,\ue41d,\ue00f,\ue41f,\ue14c,\ue32f,\ue022,\ue023,\ue110,\ue032,\ue118,\ue047,\ue045,\ue120";
    
    NSArray *emotions = [strEmotions componentsSeparatedByString:@","];
    
    for (NSString *emotion in emotions) {

        CGFloat constrainedSize = 265.0f; //or any other size
        UIFont * myFont = [UIFont fontWithName:@"Arial" size:19]; //or any other font that matches what you will use in the UILabel
        CGSize textSize = [emotion sizeWithFont: myFont
                         constrainedToSize:CGSizeMake(constrainedSize, CGFLOAT_MAX)];

        CGRect labelFrame = CGRectMake (X, Y, textSize.width + 4, textSize.height + 4 );
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text = emotion;
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor blackColor]];
        //[label setBackgroundColor:[UIColor grayColor]];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClicked:)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [label addGestureRecognizer:tapGestureRecognizer];
        
        [self.view addSubview:label];
        X += 30;
        
        if (X >300)
        {
            X = 10;
            Y += 30;
        }
        
    }
}

-(IBAction)labelClicked:(UITapGestureRecognizer*)tapGestureRecognizer
{
    UILabel *currentLabel = (UILabel *)tapGestureRecognizer.view;
    
    messageView.text = [NSString stringWithFormat:@"%@%@", messageView.text, currentLabel.text];
}

@end
