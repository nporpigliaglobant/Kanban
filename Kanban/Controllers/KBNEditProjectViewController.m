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

@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.states.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_TASKLIST_CELL forIndexPath:indexPath];
    cell.textLabel.text = [self.states objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:20];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}
- (IBAction)onSavePressed:(id)sender {
}

@end
