//
//  EditProjectViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEditProjectViewController.h"
#define TABLEVIEW_TASKLIST_CELL @"stateCell"



@interface KBNEditProjectViewController()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
@property (strong, nonatomic) NSArray* users;
@end


@implementation KBNEditProjectViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadProjectAttributes];
    self.navigationItem.title = @"Edit Project";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)loadProjectAttributes {
    self.nameTextField.text = self.project.name;
    self.descriptionTextField.text = self.project.projectDescription;
    self.projectId = self.project.projectId;
    self.users = self.project.users;
}

#pragma mark - IBActions
- (IBAction)onInviteUserPressed:(id)sender {
    //Show a simple UIAlertView with a text box.
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invite User" message:@"Enter the email address" delegate:self cancelButtonTitle:@"Invite" otherButtonTitles:nil,nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onSavePressed:(id)sender {
    [KBNAppDelegate activateActivityIndicator:YES];
    [[KBNProjectService sharedInstance] editProject:self.projectId withNewName:self.nameTextField.text withDescription:self.descriptionTextField.text completionBlock:^{
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:PROJECT_EDIT_SUCCESS andType:SUCCESS_ALERT];
        [self.navigationController popViewControllerAnimated:YES];

    } errorBlock:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
    }];
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Invite"]){
        UITextField * emailTextField = [alertView textFieldAtIndex:0];
        NSString* emailAddress = emailTextField.text;
        if ([KBNUserUtils isValidUsername:emailAddress]){
            [self sendInviteTo:emailAddress];
        }else{
            [KBNAlertUtils showAlertView:ALERT_MESSAGE_EMAIL_FORMAT_NOT_VALID andType:ERROR_ALERT];
        }
    }
}

-(void) sendInviteTo:(NSString*)emailAddress{
    

    [KBNEmailUtils sendEmailTo:emailAddress
                          from:[KBNUserUtils getUsername]
                       subject:EMAIL_INVITE_SUBJECT
                          body:EMAIL_INVITE_BODY
                     onSuccess:^(){
                         [KBNAlertUtils showAlertView:ALERT_MESSAGE_INVITE_SENT_SUCCESSFULY andType:SUCCESS_ALERT];
                         NSMutableArray* tempUsers = [self.users mutableCopy];
                         [tempUsers addObject:emailAddress];
                         self.users = [NSArray arrayWithArray:tempUsers];
                         [self.usersTableView reloadData];
                         
                     }
                       onError:^(NSError* error){
                           [KBNAlertUtils showAlertView:ALERT_MESSAGE_INVITE_SENT_SUCCESSFULY andType:ERROR_ALERT];
                       }];
    
}
@end
