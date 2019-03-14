
#include <bdn/ios/ContainerViewCore.hh>

@implementation BodenUIView
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (auto viewCore = self.viewCore.lock()) {
        viewCore->frameChanged();
    }
}

- (void)layoutSubviews
{
    if (auto viewCore = self.viewCore.lock()) {
        viewCore->startLayout();
    }
}

@end

namespace bdn::ios
{
    BodenUIView *_createContainer() { return [[BodenUIView alloc] initWithFrame:CGRectZero]; }

    ContainerViewCore::ContainerViewCore(const std::shared_ptr<bdn::UIProvider> &uiProvider)
        : ViewCore(uiProvider, _createContainer())
    {}

    ContainerViewCore::ContainerViewCore(const std::shared_ptr<bdn::UIProvider> &uiProvider,
                                         id<UIViewWithFrameNotification> view)
        : ViewCore(uiProvider, view)
    {}

    bool ContainerViewCore::canAdjustToAvailableWidth() const { return true; }

    bool ContainerViewCore::canAdjustToAvailableHeight() const { return true; }

    void ContainerViewCore::addChildView(std::shared_ptr<View> child)
    {
        if (auto childCore = child->core<ViewCore>()) {
            addChildViewCore(childCore);
            _children.push_back(child);
        } else {
            throw std::runtime_error("Cannot add this type of View");
        }

        scheduleLayout();
    }

    void ContainerViewCore::removeChildView(std::shared_ptr<View> child)
    {
        if (auto childCore = child->core<ViewCore>()) {
            childCore->removeFromUISuperview();
            _children.remove(child);
        } else {
            throw std::runtime_error("Cannot remove this type of View");
        }
        scheduleLayout();
    }

    std::list<std::shared_ptr<View>> ContainerViewCore::childViews() { return _children; }
}
