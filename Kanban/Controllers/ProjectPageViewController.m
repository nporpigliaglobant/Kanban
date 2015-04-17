//
//  ProjectPageViewController.m
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "ProjectPageViewController.h"

@interface ProjectPageViewController ()

@end

@implementation ProjectPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Task* task1 = [[Task alloc] init];
    [task1 setState:[NSNumber numberWithInt:TaskStateBacklog]];
    [task1 setName:@"Task 1"];
    [task1 setTaskDescription:@"Description of Task 1"];
    
    Task* task2 = [[Task alloc] init];
    [task2 setState:[NSNumber numberWithInt:TaskStateRequirements]];
    [task2 setName:@"Task 2"];
    [task2 setTaskDescription:@"Description of Task 2"];
    
    Task* task3 = [[Task alloc] init];
    [task1 setState:[NSNumber numberWithInt:TaskStateImplemented]];
    [task1 setName:@"Task 3"];
    [task1 setTaskDescription:@"Description of Task 3"];
    
    Task* task4 = [[Task alloc] init];
    [task1 setState:[NSNumber numberWithInt:TaskStateTested]];
    [task1 setName:@"Task 4"];
    [task1 setTaskDescription:@"Description of Task 4"];
    
    Task* task5 = [[Task alloc] init];
    [task1 setState:[NSNumber numberWithInt:TaskStateProduction]];
    [task1 setName:@"Task 5"];
    [task1 setTaskDescription:@"Description of Task 5"];
    
    self.tasks = @[task1,task2,task3,task4,task5];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectPageViewController"];
    self.pageViewController.dataSource = self;
    ProjectDetailViewController* startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.states = taskStates;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProjectDetailViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProjectDetailViewController*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [self.states count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

-(ProjectDetailViewController*)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.states count] == 0) || (index >= [self.states count]))
    {
        return nil;
    }
    
    ProjectDetailViewController *projectDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectDetailViewController"];

    projectDetailViewController.pageIndex = index;
    projectDetailViewController.tasks = [self tasksForState:(int)index];
    
    return projectDetailViewController;
}

-(NSArray*)tasksForState:(TaskState)state
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (Task* task in self.tasks) {
        if ([task.state intValue] == state){
            [result addObject:task];
        }
    }
    return result;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.states count];
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
