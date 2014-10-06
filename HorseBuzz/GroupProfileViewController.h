

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"

@interface GroupProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HTTPURLRequestDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *groupName;
@property (strong, nonatomic) IBOutlet UITableView *participants;
@property (strong, nonatomic) IBOutlet UIButton *btnParticipant;
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteExitGroup;

//The below properties using for set values from Addparticipant and Chatview controller
@property(strong ,nonatomic) NSString *getGroupId;
@property(strong ,nonatomic) NSString *getGroupName;
@property(strong,nonatomic) UIImage *getProfileImage;
@property(strong,nonatomic) NSMutableArray *getParticipant;
@property(strong ,nonatomic) NSString *buttonText;

- (IBAction)btnParticipant:(id)sender;
- (IBAction)btnDeleteExitGroup:(id)sender;

@end
