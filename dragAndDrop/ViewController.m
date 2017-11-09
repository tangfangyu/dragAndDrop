//
//  ViewController.m
//  dragAndDrop
//
//  Created by 伍明鹏 on 2017/11/9.
//  Copyright © 2017年 伍明鹏. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIDragInteractionDelegate,UIDropInteractionDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *dragImg;//拖拽目标
@property (weak, nonatomic) IBOutlet UIImageView *drogImg;//放置目标位置
@property (weak, nonatomic) IBOutlet UILabel *drogLabel;//放置目标位置

@property (strong, nonatomic) UIDragInteraction *dragInteraction;//拖拽行为
@property (strong, nonatomic) UIDropInteraction *dropInteraction;//放置行为
@end

@implementation ViewController
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.dragImg.userInteractionEnabled = YES;
    
    self.drogImg.layer.borderWidth = 0.5;
    self.drogImg.layer.borderColor = [UIColor redColor].CGColor;
    self.drogImg.layer.cornerRadius = 20;
    self.drogImg.layer.masksToBounds = YES;
    self.drogImg.userInteractionEnabled = YES;
    
    self.drogLabel.layer.borderWidth = 0.5;
    self.drogLabel.layer.borderColor = [UIColor redColor].CGColor;
    self.drogLabel.layer.cornerRadius = 20;
    self.drogLabel.layer.masksToBounds = YES;
    self.drogLabel.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dragImg addInteraction:self.dragInteraction];
    [self.drogLabel addInteraction:self.dropInteraction];
    [self.drogImg addInteraction:self.dropInteraction];
}
#pragma mark - UIDragInteractionDelegate
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
// 向当前已经存在的拖拽事件中添加一个新的 UIDragItem
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForAddingToSession:(id<UIDragSession>)session withTouchAtPoint:(CGPoint)point {
    return nil;
}

// 当 lift 动画准备执行的时候会调用该方法，可以在这个方法里面对拖动的 item 添加动画
- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session {
    NSLog(@"willAnimateLiftWithAnimator:session:");
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if (finalPosition == UIViewAnimatingPositionEnd) {
            self.dragImg.alpha = 0.6;
        }
    }];
}

// 当取消动画准备执行的时候会调用这个方法
- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator {
    NSLog(@"item:willAnimateCancelWithAnimator:");
    [animator addAnimations:^{
        self.dragImg.alpha = 1;
    }];
}

// 当用户完成一次拖拽操作，并且所有相关的动画都执行完毕的时候会调用这个方法，这时候被拖动的item 应该恢复正常的展示外观
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation {
    NSLog(@"session:didEndWithOperation:");
    [UIView animateWithDuration:0.25 animations:^{
        self.dragImg.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
//设置拖拽动作取消的视图动画 返回nil则消除动画
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForCancellingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
    NSLog(@"previewForCancellingItem");
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, interaction.view.bounds.size.width, interaction.view.bounds.size.height)];
    imageView.image = self.dragImg.image;
    
    UIDragPreviewTarget *previewTarget = [[UIDragPreviewTarget alloc] initWithContainer:interaction.view center:CGPointMake(interaction.view.bounds.size.width / 2, interaction.view.bounds.size.height / 2)];
    
    UITargetedDragPreview *dragPreview = [[UITargetedDragPreview alloc] initWithView:imageView parameters:[UIDragPreviewParameters new] target:previewTarget];
    return dragPreview;
}

#pragma mark - UIDropInteractionDelegate
//这个方法返回是否响应此放置目的地的放置请求
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    // 可以加载image或者NSString的控件都可以
    return [session canLoadObjectsOfClass:[UIImage class]] || [session canLoadObjectsOfClass:[NSString class]];
}

- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnter:(id<UIDropSession>)session {
    NSLog(@"sessionDidEnter");
}
//设置以何种方式响应拖放会话行为
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
    
    // 如果 session.localDragSession 为nil，说明这一操作源自另外一个app，
    UIDropOperation dropOperation = session.localDragSession ? UIDropOperationMove : UIDropOperationCopy;
    
    UIDropProposal *dropProposal = [[UIDropProposal alloc] initWithDropOperation:dropOperation];
    return dropProposal;
}
//这个方法当用户进行放置后会调用，可以从session中获取被传递的数据
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
//设置放置预览动画
- (UITargetedDragPreview *)dropInteraction:(UIDropInteraction *)interaction previewForDroppingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview {
    NSLog(@"previewForDroppingItem");
    if (item.localObject) {
        CGPoint dropPoint = defaultPreview.view.center;
        UIDragPreviewTarget *previewTarget = [[UIDragPreviewTarget alloc] initWithContainer:_dragImg center:dropPoint];
        return [defaultPreview retargetedPreviewWithTarget:previewTarget];
    } else {
        return nil;
    }
}

// 产生本地动画
- (void)dropInteraction:(UIDropInteraction *)interaction item:(UIDragItem *)item willAnimateDropWithAnimator:(id<UIDragAnimating>)animator {
    
    [animator addAnimations:^{
        _dragImg.alpha = 0;
    }];
    
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        _dragImg.alpha = 1;
    }];
}
#pragma mark - 懒加载
- (UIDragInteraction *)dragInteraction {
    if (!_dragInteraction) {
        //初始化
        _dragInteraction = [[UIDragInteraction alloc] initWithDelegate:self];
        //是否支持多种手势都接收响应
        _dragInteraction.allowsSimultaneousRecognitionDuringLift = YES;
        //设置是否有效
        _dragInteraction.enabled = YES;
    }
    return _dragInteraction;
}
- (UIDropInteraction *)dropInteraction {
    if (!_dropInteraction) {
        _dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
        //是否允许多个交互行为
        _dropInteraction.allowsSimultaneousDropSessions = YES;
    }
    return _dropInteraction;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
