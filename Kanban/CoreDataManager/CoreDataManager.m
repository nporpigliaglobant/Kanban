//
//  CoreDataManager.m
//  Kanban
//
//  Created by Lucas on 5/19/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



#pragma mark - Singleton method
+ (instancetype) sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.globant.SimpleKanban" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimpleKanban" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SimpleKanban.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"CoreDataHelper.Error.CouldNotGetPersistentCoordinator" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Insert object into context
-(id)insertManagedObjectOfClass:(Class)aClass inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObject* managedObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(aClass) inManagedObjectContext:managedObjectContext];
    return managedObject;
}


#pragma mark - Fetch Entity from Context
-(NSArray*)fetchEntitiesForClass:(Class)aClass withPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    NSError* error;
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:NSStringFromClass(aClass) inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    NSArray* items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"[ERROR][CoreDataHelper-fetchEntitiesForClass]%@",[error localizedDescription]);
        return nil;
    }
    else
    {
        NSLog(@"No error fetching entities. All OK");
    }
    return items;
}




/*
 Removing this, since it does not seem consistent with a Core Data approach
 -(NSArray*)getTagsForActivityId:(NSNumber*)activityId
 {
 NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id == %@",activityId];
 return [self fetchEntitiesForClass:[Tag class] withPredicate:predicate inManagedObjectContext:[self managedObjectContext]];
 }
 */

/*
-(Tag*)getTagWithId:(NSNumber*)tagId
{
    Tag* result = nil;
    if (!tagId)
    {
        NSLog(@"Warning: a nil TagID was passed to getTagWithId function");
    }
    else
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id == %@",tagId];
        NSArray* entities =  [self fetchEntitiesForClass:[Tag class] withPredicate:predicate inManagedObjectContext:_managedObjectContext];
        if ([entities count] > 0)
        {
            result = [entities objectAtIndex:0];
            if ([entities count] > 1)
            {
                NSLog(@"Warning: The query in getTagWithId(%@) returned more than one element!",tagId);
            }
        }
        else
        {
            NSLog(@"Warning: The query in getTagWithId(%@) returned zero elements!",tagId);
        }
    }
    
    return result;
}

-(Activity*)getActivityWithId:(NSNumber*)activityId
{
    Activity* result = nil;
    if (!activityId)
    {
        NSLog(@"Warning: a nil ActivityID was passed to getActivityWithId function");
    }
    else
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id == %@",activityId];
        NSArray* entities =  [self fetchEntitiesForClass:[Activity class] withPredicate:predicate inManagedObjectContext:_managedObjectContext];
        if ([entities count] > 0)
        {
            result = [entities objectAtIndex:0];
            if ([entities count] > 1)
            {
                NSLog(@"Warning: The query in getActivityWithId(%@) returned more than one element!",activityId);
            }
        }
        else
        {
            NSLog(@"Warning: The query in getActivityWithId(%@) returned zero elements!",activityId);
        }
    }
    
    return result;
}




#pragma mark - Generic method to delete a given entity from Core Data
-(void)deleteEntityNamed:(NSString*) entityName
{
    NSEntityDescription* entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    request.includesPropertyValues = NO;
    NSError *error;
    NSArray *matchingData = [[self managedObjectContext] executeFetchRequest:request error:&error];
    for (NSManagedObject *act in matchingData)
    {
        [[self managedObjectContext] deleteObject:act];
    }
}

#pragma mark - Delete Tags from Core Data
-(void)deleteAllTags
{
    [self deleteEntityNamed:@"Tag"];
}

#pragma mark - Delete Activities from Core Data
-(void)deleteAllActivities
{
    [self deleteEntityNamed:@"Activity"];
}

#pragma mark - Delete Schedules from Core Data
-(void)deleteAllSchedules
{
    [self deleteEntityNamed:@"Schedule"];
}

 
*/

@end

