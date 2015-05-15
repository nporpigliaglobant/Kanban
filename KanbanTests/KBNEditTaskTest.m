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

//Local constants
#define TASK_CREATED_EXPECTATION @"task created"
#define TASK_EDITED_EXPECTATION @"task edited"
#define TASK_EDITED_WITHOUT_NAME_EXPECTATION @"task edited without name"

#define TIMEOUT 40.0

@interface KBNEditTaskTest : XCTestCase

@end

@implementation KBNEditTaskTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

// Test description
// ----------------
// 1. Create a task.
//
// 2. Edit the task with no name. Verify that it is not updated.
//
// 3. Edit the task with a new name. Verify that it is updated.

- (void)testEditTask {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    // 1. Create a task
    
    XCTestExpectation *taskCreatedExpectation = [self expectationWithDescription:TASK_CREATED_EXPECTATION];
    
    KBNProject *project = [KBNProjectUtils projectWithParams:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"test_project_%@",dateString] forKey:PARSE_OBJECTID]];
    
    __block KBNTaskList* backlog = [KBNTaskListUtils taskListForProject:project params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        @"backlog", PARSE_OBJECTID,
                                                                                        @"backlog", PARSE_TASKLIST_NAME_COLUMN,
                                                                                        @0, PARSE_TASKLIST_ORDER_COLUMN, nil]];
    
    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];
    
    __block NSArray* retrievedTasks;
    
    // Create the task and retrieve tasks of the test project
    // NOTE: mock tasks will have fictious taskIds that should be replaced by those returned by createTasks
    NSArray *tasks = [KBNTaskUtils mockTasksForProject:project taskList:backlog quantity:1];
    KBNTask *task = tasks[0];
    
    [service createTasks:tasks
         completionBlock:^(NSDictionary *records) {
             [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
                 retrievedTasks = [records objectForKey:@"results"];
                 if (!retrievedTasks.count) { // We brought no records => error creating the tasks
                     XCTAssertTrue(false);
                 } else {
                     //update ids in tasks. NOTE: Tasks are retrieved ordered by task order.
                     NSUInteger i = 0;
                     for (NSDictionary *dict in retrievedTasks) {
                         KBNTask *task = tasks[i];
                         task.taskId = [dict objectForKey:PARSE_OBJECTID];
                         i++;
                     }
                 }
                 [taskCreatedExpectation fulfill];
                 
             } errorBlock:^(NSError *error) {
                 XCTAssertTrue(false);
                 [taskCreatedExpectation fulfill];
             }];
             
         } errorBlock:^(NSError *error) {
             XCTAssertTrue(false);
             [taskCreatedExpectation fulfill];
         }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];
    
    
    
    
    // 2. Edit the task with no name. Verify that it is not updated.
    
    XCTestExpectation *taskEditedWithoutNameExpectation = [self expectationWithDescription:TASK_EDITED_WITHOUT_NAME_EXPECTATION];
    
    task.name = @"";
    
    [service updateTask:task onSuccess:^{
        // If the task is successfully updated, the test fails
        XCTAssertTrue(false);
        [taskEditedWithoutNameExpectation fulfill];
        
    } failure:^(NSError *error) {
        // Retrieve tasks for this project and verify that task name is not blank
        [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
            retrievedTasks = [records objectForKey:@"results"];
            
            for (NSDictionary *dict in retrievedTasks) {
                NSString *name = [dict objectForKey:PARSE_TASK_NAME_COLUMN];
                if ([name isEqualToString:task.name]) {
                    XCTAssertTrue(false);
                }
            }
            
            [taskEditedWithoutNameExpectation fulfill];
            
        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [taskEditedWithoutNameExpectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];
    
    // 3. Edit the task with a new name. Verify that it is updated.
    
    XCTestExpectation *taskEditedExpectation = [self expectationWithDescription:TASK_EDITED_EXPECTATION];
    
    task.name = @"Task edited test";
    
    [service updateTask:task onSuccess:^{
        // Retrieve tasks for this project and verify that task name has been updated
        [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
            retrievedTasks = [records objectForKey:@"results"];
            
            for (NSDictionary *dict in retrievedTasks) {
                NSString *name = [dict objectForKey:PARSE_TASK_NAME_COLUMN];
                
                if (![name isEqualToString:task.name]) {
                    XCTAssertTrue(false);
                }
            }
            
            [taskEditedExpectation fulfill];
            
        } errorBlock:^(NSError *error) {
            XCTAssertTrue(false);
            [taskEditedExpectation fulfill];
        }];
    } failure:^(NSError *error) {
        XCTAssertTrue(false);
        [taskEditedExpectation fulfill];

    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT handler:^(NSError *error) {
    }];

}

@end
