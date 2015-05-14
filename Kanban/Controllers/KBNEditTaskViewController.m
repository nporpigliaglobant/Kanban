//
//  KBNEditTastViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 5/11/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEditTaskViewController.h"

@interface KBNEditTaskViewController()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@end

@implementation KBNEditTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.task.project.name;
    self.nameTextField.text = self.task.name;
    self.descriptionTextField.text = self.task.taskDescription;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onSavePressed:(id)sender {
    [KBNAppDelegate activateActivityIndicator:YES];
    self.task.name = self.nameTextField.text;
    self.task.taskDescription = self.descriptionTextField.text;
    [[KBNTaskService sharedInstance] updateTask:self.task onSuccess:^{
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:TASK_EDIT_SUCCESS andType:SUCCESS_ALERT];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
    }];
}

@end