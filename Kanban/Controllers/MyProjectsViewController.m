//
//  MyProjectsViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "MyProjectsViewController.h"
#import "ProjectDetailViewController.h"
#import "AppDelegate.h"

@interface MyProjectsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *projects;

@end

@implementation MyProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    [self addTestingProjects];
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Only for testing purposes

- (void)addTestingProjects {
    
    NSMutableArray *projectsArray = [[NSMutableArray alloc] init];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"projects" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSArray *projectList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    for (NSDictionary* item in projectList) {
        Project *newProject = [[Project alloc] initWithEntity:[NSEntityDescription entityForName:@"Project"
                                                                          inManagedObjectContext:self.managedObjectContext]
                               insertIntoManagedObjectContext:self.managedObjectContext];
        
        newProject.name = [item objectForKey:@"name"];
        newProject.projectDescription = [item objectForKey:@"projectDescription"];
        
        [projectsArray addObject:newProject];
    }
    
    self.projects = projectsArray;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectCell" forIndexPath:indexPath];
    Project *project = [self.projects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = project.name;
    
    return cell;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"addProject"]) {
        
        // TODO
        
    } else if ([segue.identifier isEqualToString:@"projectDetail"]) {
        
        ProjectDetailViewController *controller = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        controller.project = [self.projects objectAtIndex:indexPath.row];
    }
    
}


@end
