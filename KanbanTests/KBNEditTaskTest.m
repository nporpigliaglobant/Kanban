//
//  KBNEditTaskTest.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/14/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KBNProjectUtils.h"
#import "KBNTaskUtils.h"
#import "KBNTaskListUtils.h"
#import "KBNTaskService.h"
#import "KBNCreateTestEnvironment.h"

//Local constants
#define TASK_EDITED_EXPECTATION @"task edited"
#define TASK_EDITED_WITHOUT_NAME_EXPECTATION @"task edited without name"

@interface KBNEditTaskTest : XCTestCase

@end

@implementation KBNEditTaskTest
    
static KBNTask *task = nil;

+ (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    KBNCreateTestEnvironment *environment = [[KBNCreateTestEnvironment alloc] init];
    [environment createTaskEnvironment];
    task = [environment task];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


// Edit the task with no name. Verify that it is not updated.
- (void)testEditTaskWithoutName {
    
    XCTestExpectation *taskEditedWithoutNameExpectation = [self expectationWithDescription:TASK_EDITED_WITHOUT_NAME_EXPECTATION];
    
    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];
    
    task.name = @"";
    
    [service updateTask:task onSuccess:^{
        // If the task is successfully updated, the test fails
        XCTFail(@"Task was created without a name");
        [taskEditedWithoutNameExpectation fulfill];
        
    } failure:^(NSError *error) {
        [taskEditedWithoutNameExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
    }];
    
}

// Edit the task name. Verify that it is updated.
- (void)testEditTaskOK {
    
    XCTestExpectation *taskEditedExpectation = [self expectationWithDescription:TASK_EDITED_EXPECTATION];
    
    task.name = @"Task edited test";
    task.taskDescription = @"Task edited OK";
    
    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];
    
    [service updateTask:task onSuccess:^{
        // Retrieve the only task of this project and verify that its name has been updated
        NSString *projectId = task.project.projectId;
        [service getTasksForProject:projectId completionBlock:^(NSDictionary *records) {
            NSArray *retrievedTasks = [records objectForKey:@"results"];
            NSDictionary *dict = retrievedTasks[0];
            NSString *name = [dict objectForKey:PARSE_TASK_NAME_COLUMN];
            
            if (![name isEqualToString:task.name]) {
                XCTFail(@"Task name '%@' is different from '%@'", name, task.name);
            }
            
            [taskEditedExpectation fulfill];
            
        } errorBlock:^(NSError *error) {
            XCTFail(@"Task Service could not retrieve tasks for the project");
            [taskEditedExpectation fulfill];
        }];
    } failure:^(NSError *error) {
        XCTFail(@"Task Service could not update the task");
        [taskEditedExpectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
    }];
    
}

@end
