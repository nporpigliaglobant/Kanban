//
//  KBNEditTastViewController.h
//  Kanban
//
//  Created by Maximiliano Casal on 5/11/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNAlertUtils.h"
#import "KBNAppDelegate.h"
#import "KBNTaskService.h"
@interface KBNEditTaskViewController : UIViewController

@property (strong, nonatomic) KBNTask *task;

@end
