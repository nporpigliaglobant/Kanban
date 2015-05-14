//
//  KBNInviteUserTest.m
//  Kanban
//
//  Created by Lucas on 5/13/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>
#import "KBNProjectService.h"
#import <XCTest/XCTest.h>

#define EXPECTATION_NAME_CREATEPROJECT @"CreateProjectExpectation"
#define EXPECTATION_NAME_GETPROJECT_AFTER_CREATE @"GetProjectAfterCreation"
#define EXPECTATION_NAME_ADDUSER @"AddUserExpectation"
#define EXPECTATION_NAME_GETPROJECT_AFTER_ADDINGUSER @"GetProjectAfterAddingUser"
#define EXPECTATION_TIMEOUT 40.0

/**************************************************************
 This class tests the invite user feature
 - It creates a project with a username, verifying the getProject is able to retrieve it
 - It adds a user to the project. Then use the getProjects method under that user
***************************************************************/
@interface KBNInviteUserTest : XCTestCase

@end

@implementation KBNInviteUserTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddUserToProject {
    KBNProjectService* service = [KBNProjectService sharedInstance];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber* timeStampObject = [NSNumber numberWithDouble: timeStamp];
    NSString* projectName = [NSString stringWithFormat:@"InviteUserUnitTest-%@",timeStampObject];
    NSString* user = [NSString stringWithFormat:@"creatorUser%@@globant.com",timeStampObject];
    NSString* invitee = [NSString stringWithFormat:@"invitedUser%@@globant.com",timeStampObject];
    NSString* description = @"InviteUser Unit Test";
    __block KBNProject* newProject;
    
    //****************
    //Create a project
    XCTestExpectation* createProjectExpectation = [self expectationWithDescription:EXPECTATION_NAME_CREATEPROJECT];
    [service createProject:projectName
           withDescription:description
                   forUser:user
           completionBlock:^(){
                            [createProjectExpectation fulfill];}
                errorBlock:^(NSError *error){
                    XCTAssertTrue(false);
                    [createProjectExpectation fulfill];
                }];
    [self waitForExpectationsWithTimeout:EXPECTATION_TIMEOUT handler:^(NSError* error){}];
    
    
    //Get the project created
    XCTestExpectation* afterCreateProjectExpectation = [self expectationWithDescription:EXPECTATION_NAME_GETPROJECT_AFTER_CREATE];
    [service getProjectsForUser:user
                 onSuccessBlock:^(NSArray *records){
                     for (KBNProject* project in records) {
                         if ([project.name isEqualToString:projectName]){
                             newProject = project;
                         }
                     }
                     if (!newProject){
                         XCTAssertTrue(false);
                     }
                     [afterCreateProjectExpectation fulfill];
                 }
                     errorBlock:^(NSError* error){
                         XCTAssertTrue(false);
                         [afterCreateProjectExpectation fulfill];
                     }];
    [self waitForExpectationsWithTimeout:EXPECTATION_TIMEOUT handler:^(NSError* error){}];
    if (!newProject){
        XCTAssertTrue(false);
    }else{
        //***********************************************************
        //If the prior check went Okay, move on with the next part
        //Add another user to the project (other than the creator)
        XCTestExpectation* addUserExpectation = [self expectationWithDescription:EXPECTATION_NAME_ADDUSER];
        [service addUser:invitee
               toProject:newProject completionBlock:^(){
                        [addUserExpectation fulfill];
                        }
              errorBlock:^(NSError* error){
                        XCTAssertTrue(false);
                        [addUserExpectation fulfill];
                        }];
        
        [self waitForExpectationsWithTimeout:EXPECTATION_TIMEOUT
                                     handler:^(NSError* error){
                                     }];
        
        //********************************************************
        //Get the projects again and make sure the additional user
        //was actually added to the users list.
        XCTestExpectation* getProjectAfterAddingUserExpectation = [self expectationWithDescription:EXPECTATION_NAME_GETPROJECT_AFTER_ADDINGUSER];
        [service getProjectsForUser:invitee
                     onSuccessBlock:^(NSArray* records){
                                        if ([records count] == 0){
                                            XCTAssertTrue(false);
                                        }
                                        [getProjectAfterAddingUserExpectation fulfill];
                                    }
                         errorBlock:^(NSError* error){
                                        XCTAssertTrue(false);
                                        [getProjectAfterAddingUserExpectation fulfill];
                                    }];
        [self waitForExpectationsWithTimeout:EXPECTATION_TIMEOUT handler:^(NSError* error){}];
            
    }
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
