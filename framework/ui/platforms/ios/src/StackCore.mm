#import <UIKit/UIKit.h>
#import <bdn/foundationkit/stringUtil.hh>
#include <bdn/ios/ContainerViewCore.hh>
#import <bdn/ios/StackCore.hh>
#import <bdn/ios/util.hh>

@implementation BodenUINavigationControllerContainerView

- (BodenUINavigationControllerContainerView *)initWithNavigationController:
    (UINavigationController *)navigationController
{
    if (self = [super init]) {
        self.navController = navigationController;
    }
    return self;
}

- (CGRect)frame { return [super frame]; }

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    if (auto core = self.viewCore.lock()) {
        core->frameChanged();
    }
}
@end

@interface BodenStackUIViewController : UIViewController
@property(nonatomic) std::weak_ptr<bdn::ios::StackCore> stackCore;
@property(nonatomic) std::shared_ptr<bdn::FixedView> fixedView;
@property(nonatomic) std::shared_ptr<bdn::View> userContent;
@property(nonatomic) std::shared_ptr<bdn::FixedView> safeContent;
@end

@implementation BodenStackUIViewController
- (bool)isViewLoaded { return [super isViewLoaded]; }
- (void)loadViewIfNeeded { [super loadViewIfNeeded]; }

- (void)updateSafeContent
{
    if (@available(iOS 11.0, *)) {
        _safeContent->geometry = bdn::Rect{
            self.view.safeAreaInsets.left,
            self.view.safeAreaInsets.top,
            self.view.frame.size.width - (self.view.safeAreaInsets.left + self.view.safeAreaInsets.right),
            self.view.frame.size.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom),
        };
    } else {
        _safeContent->geometry = bdn::Rect{
            0,
            0,
            self.view.frame.size.width,
            self.view.frame.size.height,
        };
    }
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self updateSafeContent];
}

- (void)loadView
{
    if (auto core = _stackCore.lock()) {
        _fixedView = std::make_shared<bdn::FixedView>(core->uiProvider());
        _safeContent = std::make_shared<bdn::FixedView>(core->uiProvider());

        self.view = _fixedView->core<bdn::ios::ViewCore>()->uiView();

        _fixedView->offerLayout(core->layout());

        _fixedView->addChildView(_safeContent);
        _safeContent->addChildView(_userContent);

        _fixedView->geometry.onChange() += [=](auto) { [self updateSafeContent]; };

        auto c = std::dynamic_pointer_cast<bdn::ios::ViewCore>(_safeContent->viewCore());
        if (c) {
            // c->uiView().backgroundColor = [UIColor redColor];
            c->uiView().clipsToBounds = YES;
        }

        self.view.backgroundColor = UIColor.whiteColor;
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent { [super willMoveToParentViewController:parent]; }

- (void)didMoveToParentViewController:(UIViewController *)parent { [super didMoveToParentViewController:parent]; }

@end

namespace bdn::ios
{
    BodenUINavigationControllerContainerView *createNavigationControllerView()
    {
        UINavigationController *navigationController = [[UINavigationController alloc] init];

        BodenUINavigationControllerContainerView *view =
            [[BodenUINavigationControllerContainerView alloc] initWithNavigationController:navigationController];

        return view;
    }

    StackCore::StackCore(const std::shared_ptr<bdn::UIProvider> &uiProvider)
        : ViewCore(uiProvider, createNavigationControllerView())
    {}

    void StackCore::init()
    {
        ViewCore::init();

        UIWindow *window = [UIApplication sharedApplication].keyWindow;

        UIViewController *rootViewController = window.rootViewController;
        [rootViewController addChildViewController:getNavigationController()];
        [rootViewController.view addSubview:getNavigationController().view];
    }

    UINavigationController *StackCore::getNavigationController()
    {
        if (auto navView = (BodenUINavigationControllerContainerView *)uiView()) {
            return navView.navController;
        }
        return nullptr;
    }

    void StackCore::frameChanged()
    {
        Rect rActual = iosRectToRect(uiView().frame);
        geometry = rActual;
    }

    void StackCore::onGeometryChanged(Rect newGeometry) { uiView().frame = rectToIosRect(newGeometry); }

    std::shared_ptr<FixedView> StackCore::getCurrentContainer()
    {
        if (UIViewController *topViewController = getNavigationController().topViewController) {
            BodenStackUIViewController *bdnViewController = (BodenStackUIViewController *)topViewController;
            return bdnViewController.fixedView;
        }

        return nullptr;
    }

    std::shared_ptr<View> StackCore::getCurrentUserView()
    {
        if (UIViewController *topViewController = getNavigationController().topViewController) {
            BodenStackUIViewController *bdnViewController = (BodenStackUIViewController *)topViewController;
            return bdnViewController.userContent;
        }

        return nullptr;
    }

    void StackCore::pushView(std::shared_ptr<View> view, String title)
    {
        BodenStackUIViewController *ctrl = [[BodenStackUIViewController alloc] init];
        ctrl.stackCore = std::dynamic_pointer_cast<StackCore>(shared_from_this());
        ctrl.userContent = view;

        [ctrl setTitle:fk::stringToNSString(title)];

        [getNavigationController() pushViewController:ctrl animated:YES];

        markDirty();
    }

    void StackCore::popView()
    {
        [getNavigationController() popViewControllerAnimated:YES];
        markDirty();
    }

    std::list<std::shared_ptr<View>> StackCore::childViews()
    {
        if (auto container = getCurrentContainer()) {
            return {container};
        }
        return {};
    }
}
