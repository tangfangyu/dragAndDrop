# dragAndDrop
拖拽操作在iPad上是支持跨应用程序的，你可以从一个应用中拖取项目，通过Home键回到主界面并且打开另一个应用程序，然后将被拖拽的项目传递给这个应用程序中。在iPhone上，拖拽操作只支持当前应用程序内，你可以将某个元素从一个界面拖拽到另一个，这种维度的操作可以给设计人员更大的灵活性。拖拽操作被设计成系统管理，开发者不需要为App申请特殊的用户权限。

一、引言
在iOS11中，你可以将图片直接拖入聊天软件进行发送，可以将文档、音乐、视频文件等文件拖入相应应用程序直接进行使用。这种拖拽操作交互极大的方便了手机的使用，丰富了手机的用户体验感。

效果如图：http://g.recordit.co/BJnHxeSjXn.gif

二、涉及关键的概念
主要涉及的大体概括的对象就是： 拖拽源(按住需要拖拽的控件)、

放置目标(拖拽到的目的地)、

拖拽行为(UIDragInteraction)、

放置行为(UIDropInteraction)。

粗俗的过程：把拖拽行为加在拖拽源上，放置行为加在放置目标上，然后分别实现拖拽行为代理(UIDragInteractionDelegate)和放置行为代理方法(UIDropInteractionDelegate)，就能实现拖拽效果了。



三、UIDragInteractionDelegate协议

/**
required必须实现的代理方法
开始拖拽 添加了 UIDragInteraction 的控件 会调用这个方法，从而获取可供拖拽的 item
如果返回 nil，则不会发生任何拖拽事件
@param interaction 拖拽行为
@param session 拖拽会话
@return 返回拖拽数据源
*/
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session{
NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:@"hello world"];
UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:provider];

NSItemProvider *provider1 = [[NSItemProvider alloc] initWithObject:self.dragImg.image];
UIDragItem *dragItem1 = [[UIDragItem alloc] initWithItemProvider:provider1];
return @[dragItem,dragItem1];
}




/**
optional选择实现的代理方法
对刚开始拖动处于 lift 状态的 item 会有一个 preview 的预览功效，其动画是系统自动生成的，但是需要我们通过该方法提供 preview 的相关信息
如果返回 nil，就相当于指明该 item 没有预览效果
如果没有实现该方法，interaction.view 就会生成一个 UITargetedDragPreview
*/
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session{
UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:self.dragImg.bounds cornerRadius:10];
UITargetedDragPreview *preView = [[UITargetedDragPreview alloc] initWithView:interaction.view parameters:parameters];
return preView;
}



向当前已经存在的拖拽事件中添加一个新的 UIDragItem
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForAddingToSession:(id<UIDragSession>)session withTouchAtPoint:(CGPoint)point



拖拽不同阶段的动画
当 lift 动画准备执行的时候会调用该方法
- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session

当取消动画准备执行的时候会调用这个方法
- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator

当用户完成一次拖拽操作，并且所有相关的动画都执行完毕的时候会调用这个方法，这时候被拖动的item 应该恢复正常的展示外观
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation

设置拖拽动作取消的视图动画 返回nil则消除动画
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForCancellingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview

四、UIDropInteractionDelegate协议

这个方法返回是否响应此放置目的地的放置请求
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
// 可以加载image或者NSString的控件都可以
return [session canLoadObjectsOfClass:[UIImage class]] || [session canLoadObjectsOfClass:[NSString class]];
}



这个方法当用户进行放置后会调用，可以从session中获取被传递的数据
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
NSLog(@"performDrop");
//在这个方法内部也要判断是否源自本app
if (session.localDragSession) {
if ([session canLoadObjectsOfClass:[NSString class]]) {
[session loadObjectsOfClass:[NSString class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
self.drogLabel.text = objects.firstObject;
}];
}
if ([session canLoadObjectsOfClass:[UIImage class]]){
[session loadObjectsOfClass:[UIImage class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
self.drogImg.image = objects.lastObject;
}];
}
}
}



设置以何种方式响应拖放会话行为
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session



设置放置预览动画
- (UITargetedDragPreview *)dropInteraction:(UIDropInteraction *)interaction previewForDroppingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview

简单的实现就是这样，里面还涉及到很多，就不一一讲述，喜欢的给个start。谢谢
