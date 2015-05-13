//
//  EditProjectViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEditProjectViewController.h"
#define TABLEVIEW_TASKLIST_CELL @"stateCell"
#define TABLEVIEW_USERSLIST_CELL @"usersListCell"

//Alert messages
#define ALERT_MESSAGE_EMAIL_FORMAT_NOT_VALID @"The format of the email address entered is not valid"
#define ALERT_MESSAGE_INVITE_SENT_SUCCESSFULY @"Email sent successfuly!"
#define ALERT_MESSAGE_INVITE_FAILED @"Sorry, the invite could not be sent at this time. Try again later"

@interface KBNEditProjectViewController()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
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
    //Add the user to the project. If the update goes well then send the email with the invite.
    __weak typeof(self) weakSelf = self;
    [[KBNProjectService sharedInstance] addUser:emailAddress
                             toProject:self.project
                       completionBlock:^{
                                         [KBNEmailUtils sendEmailTo:emailAddress
                                                 from:[KBNUserUtils getUsername]
                                              subject:EMAIL_INVITE_SUBJECT
                                                 body:EMAIL_INVITE_BODY
                                            onSuccess:^(){
                                                //Refresh the table view
                                                [weakSelf.usersTableView reloadData];
                                                //Let the user know everything went OK...
                                                [KBNAlertUtils showAlertView:ALERT_MESSAGE_INVITE_SENT_SUCCESSFULY andType:SUCCESS_ALERT];                                                
                                            }
                                              onError:^(NSError* error){
                                                  [KBNAlertUtils showAlertView:ALERT_MESSAGE_INVITE_FAILED andType:ERROR_ALERT];
                                              }];
                                       }
                            errorBlock:^(NSError *error) {
                                       }];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.project.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_USERSLIST_CELL forIndexPath:indexPath];
    NSString* userEmail = [self.project.users objectAtIndex:indexPath.row];
    cell.textLabel.text = userEmail;
    //cell.textLabel.font = [UIFont getTableFont];
    //cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
