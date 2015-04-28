//
//  EditProjectViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEditProjectViewController.h"
#define TABLEVIEW_TASKLIST_CELL @"TaskCell"

@interface KBNEditProjectViewController()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tasklists;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@end


@implementation KBNEditProjectViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    [self loadProjectAttributes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)loadProjectAttributes {
    self.nameTextField.text = self.project.name;
    self.descriptionTextField.text = self.project.projectDescription;
    self.tasklists = self.project.taskLists.array;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasklists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_TASKLIST_CELL forIndexPath:indexPath];
    KBNTaskList *tasklist = [self.tasklists objectAtIndex:indexPath.row];
    cell.textLabel.text = tasklist.name;
    
    return cell;
}
- (IBAction)onSavePressed:(id)sender {
}

@end
