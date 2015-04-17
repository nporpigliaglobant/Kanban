//
//  ProjectPageViewController.h
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "ProjectDetailViewController.h"
#import "Constants.h"

@interface ProjectPageViewController : UIViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray* tasks;
@property (strong, nonatomic) NSArray* states;

@end
