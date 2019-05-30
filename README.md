#  RunLoop

> A run loop is an event processing loop that you use to schedule work and coordinate the receipt of incoming events. The purpose of a run loop is to keep your thread *busy* when there is work to do and put your thread to *sleep* when there is none.

Two way to use RunLoop:
Cocoa: NSRunLoop
CoreFundation: CFRunLoop

RunLoop is an open source that you can download it [here](https://opensource.apple.com/tarballs/CF).

## RunLoop作用

1. 线程保活；
2. 线程/进程之间的通信；
3. 响应事件（Touch、performSelector:on、timer）；
4. 节省资源CPU资源、提高程序性能（busy 、sleep，用户态与内核态切换）；

## RunLoop特点
1. 线程与runloop一一对应，底层用字典来存储runloop，以线程的指针为key，runloop为value。
2. app启动Main Thread默认开启了runloop；
3. 子线程默认未创建且未开启子线程，当第一次访问子线程的runloop时才创建；

## RunLoop模式
能够被用户使用的模式：
1. NSDefaultRunLoopMode(KCFRunLoopDefaultMode)
2. NSEventTrackingRunLoopMode(UITracking)
3. NSRunLoopCommonModes(KCFRunLoopCommonMode)
其它模式：
4. NSRunLoopCommonModes
5. NSModalPanelRunLoopMode

## RunLoop Sources

### Input Source
> Input sources deliver events asynchronously to your threads.
> The only difference between the two sources is how they are signaled. Port-based sources are signaled automatically by the kernel, and custom sources must be signaled manually from another thread.


#### Port-Based Source
通过创建NSPort, 将其加入对应的runloop, 两个线程可以通过代理 NSMachPortDelegate中的回调方法
`- (void)handlePortMessage:(NSPortMessage *)message;`
进行通信。
NSPortMessage类：
``` Objective-C
@interface NSPortMessage : NSObject {
@private
NSPort         *localPort;
NSPort         *remotePort;
NSMutableArray     *components;
uint32_t        msgid;
void        *reserved2;
void        *reserved;
}

- (instancetype)initWithSendPort:(nullable NSPort *)sendPort receivePort:(nullable NSPort *)replyPort components:(nullable NSArray *)components NS_DESIGNATED_INITIALIZER;

@property (nullable, readonly, copy) NSArray *components;
@property (nullable, readonly, retain) NSPort *receivePort;
@property (nullable, readonly, retain) NSPort *sendPort;
- (BOOL)sendBeforeDate:(NSDate *)date;

@property uint32_t msgid;

@end
```

#### Custom Input Source
1. 使用*CFRunLoopSourceRef*直接创建runloop的自定义source;
2. 通过配置*CFRunLoopSourceContext*定义三个回调函数;
3. 将souces添加到某个runloop中；
4. 手动发送信号`CFRunLoopSourceSignal(source); // 打印schedule`
5. 手动唤醒runloop`CFRunLoopSourceSignal(source); // 打印schedule`
6. 手动从runloop中移除`CFRunLoopRemoveSource(rl, source, kCFRunLoopDefaultMode); // 打印cancel`
7. 释放CF资源`CFRelease(source);`

### Cocoa Perform Selector Sources
1. 可以同步执行selector到任意线程中；
2. 当selector执行完毕后，该source会自动从其所在的runloop中移除；
3. 当在thread1中让thread2执行某selector时，必须保证thread1时active状态（即调用过run）；
4. 包含的方法：
- selector加到主线程中
 ```
performSelectorOnMainThread:withObject:waitUntilDone:
performSelectorOnMainThread:withObject:waitUntilDone:modes:
```
- selector加到任意线程中
```
performSelector:onThread:withObject:waitUntilDone:
performSelector:onThread:withObject:waitUntilDone:modes:
```
- selector在当前线程中延迟执行
```
performSelector:withObject:afterDelay:
performSelector:withObject:afterDelay:inModes:
```
- 取消当前线程的selector消息
```
cancelPreviousPerformRequestsWithTarget:
cancelPreviousPerformRequestsWithTarget:selector:object:
```

### Timer Sources
在cocoa框架中可以直接使用NSTimer的方法
```
scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:
scheduledTimerWithTimeInterval:invocation:repeats:
```
1. scheduledTimerWithTimeInterval:方法默认将timer加入到了当前线程的default模式；
2. 主线程中，滑动textView时，timer停止回调；
3. 解决2.中问题的方案一是将timer再加入*UITrackingRunLoopMode*，方案二是将timer放入子线程中执行。

## RunLoop Observers
1. Observer可以接收到runloop的执行事件的通知，如：
- The entrance to the run loop.
- When the run loop is about to process a timer.
- When the run loop is about to process an input source.
- When the run loop is about to go to sleep.
- When the run loop has woken up, but before it has processed the event that woke it up.
- The exit from the run loop.
2. CFRunLoopObserverRef 创建observer，observer像NSTimer一样，既可以在一次观察后就从runloop 中移除，也可以重复性的观察。

### The RunLoop Sequence of Event

1. Notify observers that the run loop has been entered.
2. Notify observers that any ready timers are about to fire.
3. Notify observers that any input sources that are not port based are about to fire.
4. Fire any non-port-based input sources that are ready to fire.
5. If a port-based input source is ready and waiting to fire, process the event immediately. Go to step 9.
6. Notify observers that the thread is about to sleep.
7. Put the thread to sleep until one of the following events occurs:
- An event arrives for a port-based input source.
- A timer fires.
- The timeout value set for the run loop expires.
- The run loop is explicitly woken up.
8. Notify observers that the thread just woke up.
9. Process the pending event.
- If a user-defined timer fired, process the timer event and restart the loop. Go to step 2.
- If an input source fired, deliver the event.
- If the run loop was explicitly woken up but has not yet timed out, restart the loop. Go to step 2.
10. Notify observers that the run loop has exited.

## When Would You Use a Run Loop?
在主线程中肯定是不需要开启lunloop的，因为主线程中默认开启了。在子线程中如果需要，就要手动开启runloop.通常以下情况可以使用runloop：
- Use ports or custom input sources to communicate with other threads.
- Use timers on the thread.
- Use any of the performSelector… methods in a Cocoa application.
- Keep the thread around to perform periodic tasks.
如果在子线程中使用runloop，一定要清楚什么时候停止runloop，否则容让造成一些内存泄漏的问题。

## RunLoop在开发中的应用
### 解决UI操作时，timer停止回调的问题；
### 列表中imageView延迟加载图片，提升APP性能；
### 线程保活

##RunLoop在系统中的体现
### AutoreleasePool
observer1 ----> Entry ------->do objc_autoreleasePoolPush() 创建自动释放池;
observer2 -----> BeforeWaiting --------->do  _objc_autoreleasePoolPop() 和 _objc_autoreleasePoolPush() 释放旧的池并创建新池;
                 -----> Exit --------> do _objc_autoreleasePoolPop() 
关键词： 环绕所有事件的回调，及时回收。
###  事件响应
1. Source1 (基于 mach port 的) 用来接收系统事件；
2. 回调函数__IOHIDEventSystemClientQueueCallback();
3. 硬件事件 ->IOKit.framework -> IOHIDEvent -> Mach Port -> source1 -> _UIApplicationHandleEventQueue()  -> 识别硬件事件类型（如旋转、button点击等）-> UIWindow ->从window开始 hitTest:withEvent: 寻找point所在的view -> 寻找能响应该事件的view
### 更新界面
observer2会去遍历所有需要更新UI的事件，并执行。
### 定时器
### performselector
### GCD
dispatch_async(dispatch_get_main_queue(), block)
### 网络请求
CFSocket
CFNetwork
NSURLConnection AFNetworking
NSURLSession(iOS7 *) AFNetworking2, Alamofire

