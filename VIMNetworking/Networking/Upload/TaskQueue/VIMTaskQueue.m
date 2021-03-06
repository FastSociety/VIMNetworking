//
//  UploadQueue.m
//  Pegasus
//
//  Created by Hanssen, Alfie on 2/13/15.
//  Copyright (c) 2014-2015 Vimeo (https://vimeo.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "VIMTaskQueue.h"
#import "VIMTask.h"
#import "VIMTaskQueueDebugger.h"

NSString *const VIMTaskQueueTaskFailedNotification = @"VIMTaskQueueTaskFailedNotification";
NSString *const VIMTaskQueueTaskSucceededNotification = @"VIMTaskQueueTaskSucceededNotification";

static NSString *TasksKey = @"tasks";
static NSString *CurrentTaskKey = @"current_task";

static void *TaskQueueSpecific = "TaskQueueSpecific";

@interface VIMTaskQueue () <VIMTaskDelegate>
{
    dispatch_queue_t _archivalQueue;
    dispatch_queue_t _tasksQueue;
}

@property (nonatomic, strong, readwrite) NSString *name;

@property (nonatomic, assign, getter=isSuspended) BOOL suspended;

@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, assign, readwrite) NSInteger taskCount;

@property (nonatomic, strong, readwrite) VIMTask *currentTask;

@end

@implementation VIMTaskQueue

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _name = name;
        
        _archivalQueue = dispatch_queue_create("com.vimeo.uploadQueue.archivalQueue", DISPATCH_QUEUE_SERIAL);
        _tasksQueue = dispatch_queue_create("com.vimeo.uploadQueue.taskQueue", DISPATCH_QUEUE_SERIAL);

        dispatch_queue_set_specific(_tasksQueue, TaskQueueSpecific, (void *)TaskQueueSpecific, NULL);

        _tasks = [NSMutableArray array];

        [self load];
        
        self.suspended = YES; // So that superclass can call [self resume] [AH]
    }
    
    return self;
}

#pragma mark - Public API

- (void)addTasks:(NSArray *)tasks
{
    if (![tasks count])
    {
        return;
    }
    
    dispatch_async(_tasksQueue, ^{

        [self.tasks addObjectsFromArray:tasks];

        // order important check self.tasks then currentTask
        for (VIMTask *currentTask in tasks)
        {
            currentTask.delegate = self;
        }
        
        [self save];
        
        [self updateTaskCount];
        
        if (self.currentTask == nil)
        {
            [self startNextTask];
        }

    });
}

- (void)addTask:(VIMTask *)task
{
    if (!task)
    {
        return;
    }
    
    dispatch_async(_tasksQueue, ^{
        
        [self.tasks addObject:task];
        task.delegate = self;
        
        [self save];
        
        [self updateTaskCount];
        
        if (self.currentTask == nil)
        {
            [self startNextTask];
        }
        
    });
}

// private prepend task must be called from within tasksQueue thread
- (void)_prependTask:(VIMTask *)task
{
    if (!task)
    {
        return;
    }
    
    [self.tasks insertObject:task atIndex:0];
    
    [self save];
    
    [self updateTaskCount];
    
    if (self.currentTask == nil)
    {
        [self startNextTask];
    }
}


- (void)cancelAllTasks
{
    dispatch_async(_tasksQueue, ^{
        
        [self.tasks removeAllObjects];
        
        [self.currentTask cancel];
        
        self.currentTask = nil;
        
        [self updateTaskCount];
        
    });
}

- (void)cancelTask:(VIMTask *)task
{
    if (!task)
    {
        return;
    }

    dispatch_async(_tasksQueue, ^{
        
        if (self.currentTask == task)
        {
            [self.currentTask cancel];
        }
        else
        {
            [self.tasks removeObject:task];
            [task cancel];
        }
        
        [self save];
        
        [self updateTaskCount];
        
    });
}

- (void)suspend
{
    if (self.isSuspended)
    {
        return;
    }
    
    self.suspended = YES;
    
    dispatch_async(_tasksQueue, ^{

        if (self.currentTask)
        {
            [self.currentTask suspend];
        }
        
        [self save];
        
    });
}

- (void)resume
{
    if (!self.isSuspended)
    {
        return;
    }

    self.suspended = NO;
    
    dispatch_async(_tasksQueue, ^{

        [self save];

        [self restart];
    
    });
}

- (void)cancelTaskForIdentifier:(nullable NSString *)identifier
{
    if (!identifier)
    {
        return;
    }
    
    dispatch_async(_tasksQueue, ^{
        
        __block VIMTask *task = nil;
        
        task = [self _taskForIdentifier:identifier];

        if (self.currentTask == task)
        {
            [self.currentTask cancel];
        }
        else
        {
            [self.tasks removeObject:task];
            [task cancel];
        }
        
        [self save];
        
        [self updateTaskCount];
        
    });
}


- (void)pauseTaskForIdentifier:(nullable NSString *)identifier
{
    if (!identifier)
    {
        return;
    }
    
    dispatch_sync(_tasksQueue, ^{
    
        if ([self.currentTask.identifier isEqualToString:identifier])
        {
            [self.currentTask pause];
            [self _prependTask: self.currentTask];
            self.currentTask = nil;
        }
        else
        {
            // order important check self.tasks then currentTask
            for (VIMTask *currentTask in self.tasks)
            {
                if ([currentTask.identifier isEqualToString:identifier])
                {
                    [currentTask pause];
                    break;
                }
            }
        }
        
        [self save];
        
        [self restart];        
        
    });
}

- (void)resumeTaskForIdentifier:(nullable NSString *)identifier
{
    if (!identifier)
    {
        return;
    }

    dispatch_sync(_tasksQueue, ^{

        // currentTask can never be paused by design
        
        for (VIMTask *currentTask in self.tasks)
        {
            if ([currentTask.identifier isEqualToString:identifier])
            {
                // change state from paused to none so task will be executed at next opportunity
                [currentTask resumeAfterPause];
                break;
            }
        }
        
        [self save];
        
        [self restart];
    });
}

- (VIMTask *)taskForIdentifier:(NSString *)identifier
{
    if (!identifier)
    {
        return nil;
    }
    
    __block VIMTask *task = nil;

    if (dispatch_get_specific(TaskQueueSpecific))
    {
        task = [self _taskForIdentifier:identifier];
    }
    else
    {
        // This will block until any activity in _tasksQueue is running, the longest could be when
        //  [self.currentTask resume] is doing a file copy in the resume, solution would be to
        
        dispatch_sync(_tasksQueue, ^{ // TODO: Is this a problem when [self.tasks count] is large? [AH]

            task = [self _taskForIdentifier:identifier];
            
        });
    }
    
    return task;
}

- (VIMTask *)_taskForIdentifier:(NSString *)identifier
{
    VIMTask *task = nil;
    
    if ([self.currentTask.identifier isEqualToString:identifier])
    {
        task = self.currentTask;
    }
    else
    {
        for (VIMTask *currentTask in self.tasks)
        {
            if ([currentTask.identifier isEqualToString:identifier])
            {
                task = currentTask;
            }
        }
    }
    
    return task;
}

- (void)mapBlock:(TaskQueueProcessBlock)taskProcessor
{
    if (taskProcessor == nil) {
        return;
    }
    
    dispatch_sync(_tasksQueue, ^{
        
        if (self.currentTask != nil) {
            taskProcessor(self.currentTask);
        }
                
        for (VIMTask *currentTask in self.tasks)
        {
            taskProcessor(currentTask);
        }
        
    });
}

- (void)prepareTask:(VIMTask *)task
{
    // Optional subclass override
}

- (NSUserDefaults *)taskQueueDefaults
{
    // Optional subclass override

    return [NSUserDefaults standardUserDefaults];
}

#pragma mark - Private API

- (void)restart
{
    if (self.currentTask == nil)
    {
        [self startNextTask]; // TODO: possible (rare) threadsafety issue [AH]
    }
    else
    {
        [self prepareTask:self.currentTask]; // In the event of a restart that occurs on launch [AH]
        
        [self.currentTask resume];
    }
}

// this method must be called within the task queue thread/safety [ME]
-  (nullable VIMTask *)getNextActiveTask
{
    VIMTask *task = nil;

    NSUInteger i = 0;
    
    for (VIMTask *currentTask in self.tasks)
    {
        if (currentTask.state != TaskStatePaused) {
            task = currentTask;
            [self.tasks removeObjectAtIndex:i];
            break;
        }
        i++;
    }
    
    return task;
}

- (void)startNextTask
{
    if (self.isSuspended)
    {
        return;
    }
    
    if (![self.tasks count])
    {
        [VIMTaskQueueDebugger postLocalNotificationWithContext:self.name message:@"NEXT 0: queue complete!"];
        
        return;
    }
    
    [VIMTaskQueueDebugger postLocalNotificationWithContext:self.name message:@"NEXT"];
    
//    self.currentTask = [self.tasks firstObject];
//    [self.tasks removeObjectAtIndex:0];

    // get next active (non-paused) task
    self.currentTask = [self getNextActiveTask];
    
    [self prepareTask:self.currentTask];

    [self save];
    
    [self.currentTask resume];
}

- (void)updateTaskCount
{
    NSInteger count = [self.tasks count];
    
    if (self.currentTask)
    {
        count += 1;
    }
    
    self.taskCount = count;
}

#pragma mark - Archival

- (void)save
{
    
    NSDictionary *dictionary = @{TasksKey : [self.tasks copy]};
    NSMutableDictionary *archiveDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    if (self.currentTask)
    {
        archiveDictionary[CurrentTaskKey] = self.currentTask;
    }
    
//    NSLog(@"SAVING: %@", dictionary);
    
    __weak typeof(self) welf = self;
    dispatch_async(_archivalQueue, ^{
        
        __strong typeof(self) strongSelf = welf;
        if (strongSelf == nil)
        {
            return;
        }
        
        NSMutableData *data = [NSMutableData new];
        NSKeyedArchiver *keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        
        [keyedArchiver encodeObject:archiveDictionary];
        [keyedArchiver finishEncoding];
        
        [[strongSelf taskQueueDefaults] setObject:data forKey:strongSelf.name];
        [[strongSelf taskQueueDefaults] synchronize];
        
//        NSString *message = [NSString stringWithFormat:@"SAVE %lu", (unsigned long)[dictionary[TasksKey] count]];
//        [UploadDebugger postLocalNotificationWithContext:strongSelf.name message:message];
    });
}

- (void)load
{
    NSAssert([self.tasks count] == 0, @"Task array must be empty at time of load.");

    NSData *data = [[self taskQueueDefaults] objectForKey:self.name];
    if (data)
    {
        NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSDictionary *dictionary = nil;
        
        @try
        {
            dictionary = [keyedUnarchiver decodeObject];
        }
        @catch (NSException *exception)
        {
            NSLog(@"An exception occured while unarchiving export operations: %@", exception);
            
            [[self taskQueueDefaults] removeObjectForKey:self.name];
            [[self taskQueueDefaults] synchronize];
        }
        
        [keyedUnarchiver finishDecoding];
        
        if (dictionary)
        {
            self.currentTask = dictionary[CurrentTaskKey];

            if (self.currentTask != nil) {
                self.currentTask.delegate = self;
            }

            NSArray *tasks = dictionary[TasksKey];
            [self.tasks addObjectsFromArray:tasks];

            for (VIMTask *currentTask in tasks)
            {
                currentTask.delegate = self;
            }
            
            [self updateTaskCount];
            
            NSString *message = [NSString stringWithFormat:@"LOAD %lu", (unsigned long)[tasks count]];
            [VIMTaskQueueDebugger postLocalNotificationWithContext:self.name message:message];
        }
        else
        {
            [VIMTaskQueueDebugger postLocalNotificationWithContext:self.name message:@"LOAD 0"];
        }
    }
}

#pragma mark - Task Delegate

- (void)taskDidStart:(VIMTask *)task
{

}

- (void)task:(VIMTask *)task didStartSubtask:(VIMTask *)subtask
{
    [self save];
}

- (void)task:(VIMTask *)task didCompleteSubtask:(VIMTask *)subtask
{
    [self save];

    [self logTaskStatus:subtask];
}

- (void)taskDidComplete:(VIMTask *)task
{
    // Determined at WWDC 2015 in concert with an Apple Foundation engineer that dispatch_sync is the appropriate mechanism to use here [AH]
    // The intent is for this to not adversely impact session delegate completionHandler call
    
    if (dispatch_get_specific(TaskQueueSpecific))
    {
        [self respondToTaskCompletion:task];
    }
    else
    {
        dispatch_sync(_tasksQueue, ^{
            [self respondToTaskCompletion:task];
        });
    }
}

- (void)respondToTaskCompletion:(VIMTask *)task
{
    self.currentTask = nil;
    
    [self save];
    
    [self updateTaskCount];
    
    [self logTaskStatus:task];
    
    if ([task didSucceed])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VIMTaskQueueTaskSucceededNotification object:task];
    }
    else if (task.error.code != NSURLErrorCancelled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VIMTaskQueueTaskFailedNotification object:task];
    }
    
    [self startNextTask];
    
}
- (void)logTaskStatus:(VIMTask *)task
{
    if ([task didSucceed])
    {
        [VIMTaskQueueDebugger postLocalNotificationWithContext:self.name message:[NSString stringWithFormat:@"%@ succeeded", task.name]];
    }
    else
    {
        if (task.error.code == NSURLErrorCancelled)
        {
            [VIMTaskQueueDebugger postLocalNotificationWithContext:self.name message:[NSString stringWithFormat:@"%@ cancelled", task.name]];
        }
        else
        {
            [VIMTaskQueueDebugger postLocalNotificationWithContext:self.name message:[NSString stringWithFormat:@"%@ failed %@", task.name, task.error]];
        }
    }
}

- (dispatch_queue_t)tasksQueue
{
    return _tasksQueue;
}

@end
