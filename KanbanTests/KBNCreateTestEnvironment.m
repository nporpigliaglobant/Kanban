//
//  KBNCreateTestEnvironment.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNCreateTestEnvironment.h"

#define TASK_CREATED_EXPECTATION @"task created"

@interface KBNCreateTestEnvironment()

@end

@implementation KBNCreateTestEnvironment

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateTaskEnvironment {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMYYHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    XCTestExpectation *taskCreatedExpectation = [self expectationWithDescription:TASK_CREATED_EXPECTATION];
    
    KBNProject *project = [KBNProjectUtils projectWithParams:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"test_project_%@",dateString] forKey:PARSE_OBJECTID]];
    
    __block KBNTaskList* backlog = [KBNTaskListUtils taskListForProject:project params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        @"backlog", PARSE_OBJECTID,
                                                                                        @"backlog", PARSE_TASKLIST_NAME_COLUMN,
                                                                                        @0, PARSE_TASKLIST_ORDER_COLUMN, nil]];
    
    KBNTaskService * service = [[KBNTaskService alloc]init];
    service.dataService =[[KBNTaskParseAPIManager alloc]init];
    
    // Create the task and retrieve tasks of the test project
    // NOTE: mock task will have fictious taskIds that should be replaced by those returned by createTasks
    self.task = [KBNTaskUtils mockTaskForProject:project taskList:backlog];
    
    [service createTask:self.task inList:backlog completionBlock:^(NSDictionary *records) {
        __weak typeof(self) weakself = self;
        [service getTasksForProject:project.projectId completionBlock:^(NSDictionary *records) {
            NSArray *retrievedTasks = [records objectForKey:@"results"];
            if (!retrievedTasks.count) { // We brought no records => error creating the tasks
                XCTAssertTrue(false);
            } else if (retrievedTasks.count > 1){ // if we bring more than one task, that´s an error.
                XCTAssertTrue(false);
            } else {
                //update id in task.
                NSDictionary *dict = retrievedTasks[0];
                weakself.task.taskId = [dict objectForKey:PARSE_OBJECTID];
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
    
    [self waitForExpectationsWithTimeout:40 handler:^(NSError *error) {
    }];
    
}

@end