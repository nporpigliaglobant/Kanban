//
//  KBNCreateTestEnvironment.h
//  Kanban
//
//  Created by Marcelo Dessal on 5/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectUtils.h"
#import "KBNTaskListUtils.h"
#import "KBNTaskUtils.h"
#import "KBNTaskService.h"
#import "KBNConstants.h"

@interface KBNCreateTestEnvironment : XCTestCase

@property (strong, nonatomic) KBNTask *task;

- (void)testCreateTaskEnvironment;

@end
