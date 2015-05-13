//
//  KBNProjectService.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectService.h"

@implementation KBNProjectService

//This method is because KBNProxy is a Singleton
+(KBNProjectService *) sharedInstance{
    
    static  KBNProjectService *inst = nil;
    
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
            inst.dataService = [[KBNProjectParseAPIManager alloc]init];
        }
    }
    return inst;
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}


-(void)createProject:(NSString*)name withDescription:(NSString*)projectDescription forUser:(NSString*) username completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    if ([name isEqualToString:@""] || !name) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": CREATING_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }else{
        KBNProject *project = [[KBNProject alloc]initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        project.name = name;
        project.projectDescription = projectDescription;
        project.users = [NSArray arrayWithObject:username];
        [self.dataService createProject:project completionBlock:onCompletion errorBlock:onError ] ;
    }
}

-(void)editProject: (NSString*)projectID withNewName:(NSString*)newName withDescription:(NSString*)newDescription completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    if ([projectID isEqualToString:@""] || [newName isEqualToString:@""] || [newDescription isEqualToString:@""]) {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": EDIT_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }else{
        [self.dataService editProject:projectID withNewName:newName withNewDesc:newDescription completionBlock:onCompletion errorBlock:onError];
    }
}


-(BOOL)project:(KBNProject*)project hasUser:(NSString*)emailAddress{
    BOOL result = NO;
    NSArray* users = (NSArray*)project.users;
    for (NSString* emailAddressInArray in users) {
        if ([emailAddressInArray isEqualToString:emailAddress]){
            result = YES;
            break;
        }
    }
    return result;
}

//Adds a email address to the participants list of a given project.
-(void)addUser:(NSString*)emailAddress
          toProject:(KBNProject*)aProject
    completionBlock:(KBNConnectionSuccessBlock)onSuccess
         errorBlock:(KBNConnectionErrorBlock)onError
{
    if ([aProject.projectId isEqualToString:@""])
    {
        NSString *domain = ERROR_DOMAIN;
        NSDictionary * info = @{@"NSLocalizedDescriptionKey": EDIT_PROJECT_WITHOUTNAME_ERROR};
        NSError *errorPtr = [NSError errorWithDomain:domain code:-102
                                            userInfo:info];
        onError(errorPtr);
    }
    else
    {
        if (![self project:aProject hasUser:emailAddress])
        {
            //Add the user email at the top
            NSMutableArray* usersMutableArray = [[NSMutableArray alloc]init];
            [usersMutableArray addObject:emailAddress];
            [usersMutableArray addObjectsFromArray:aProject.users];
            
            NSArray* newUsersArray = [NSArray arrayWithArray:usersMutableArray];
            [self.dataService setUsersList:newUsersArray toProjectId:aProject.projectId completionBlock:^(){
                aProject.users = newUsersArray;
                onSuccess();
            } errorBlock:onError];
        }
    }
}

-(void)removeProject:(NSString*)name completionBlock:(KBNConnectionSuccessBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    
}

-(KBNProject*) getProjectWithName: (NSString*)name errorBlock:(KBNConnectionErrorBlock)onError{
    return nil;
}

-(void)getProjectsForUser: (NSString*) username onSuccessBlock:(KBNConnectionSuccessArrayBlock)onCompletion errorBlock:(KBNConnectionErrorBlock)onError{
    
    __weak typeof(self) weakself = self;
    
    [self.dataService getProjectsFromUsername:username onSuccessBlock:^(NSDictionary *records) {
        NSMutableArray *projectsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary* item in records) {
            KBNProject *newProject = [[KBNProject alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT
                                                                                    inManagedObjectContext:weakself.managedObjectContext]
                                         insertIntoManagedObjectContext:weakself.managedObjectContext];
            
            // newProject.projectId = [item objectForKey:PARSE_OBJECTID];
            newProject.name = [item objectForKey:PARSE_PROJECT_NAME_COLUMN];
            newProject.projectDescription = [item objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN];
            newProject.projectId = [item objectForKey:PARSE_OBJECTID];
            NSMutableArray* tempUsersList = [[NSMutableArray alloc] init];
            for (NSString* usersListItem in [item objectForKey:PARSE_PROJECT_USERSLIST_COLUMN]) {
                [tempUsersList addObject:usersListItem];
            }
            newProject.users = [NSArray arrayWithArray:tempUsersList];
            [projectsArray addObject:newProject];
        }
        onCompletion(projectsArray);
    } errorBlock:onError];
}

@end
