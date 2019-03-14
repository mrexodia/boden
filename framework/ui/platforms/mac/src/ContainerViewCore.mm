
#import <bdn/mac/ContainerViewCore.hh>

/** NSView implementation that is used internally by
 bdn::mac::ContainerViewCore.

 Sets the flipped property so that the coordinate system has its origin in the
 top left, rather than the bottom left.
 */
@interface BdnMacContainerView_ : NSView
@property std::weak_ptr<bdn::ViewCore> viewCore;
@end

@implementation BdnMacContainerView_

- (BOOL)isFlipped { return YES; }

- (void)layout
{
    if (auto viewCore = self.viewCore.lock()) {
        viewCore->startLayout();
    }
}

@end

namespace bdn::mac
{
    NSView *ContainerViewCore::_createContainer()
    {
        BdnMacContainerView_ *macContainerView = [[BdnMacContainerView_ alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        return macContainerView;
    }

    ContainerViewCore::ContainerViewCore(const std::shared_ptr<bdn::UIProvider> &uiProvider)
        : ContainerViewCore(uiProvider, _createContainer())
    {}

    ContainerViewCore::ContainerViewCore(const std::shared_ptr<bdn::UIProvider> &uiProvider, NSView *view)
        : bdn::mac::ViewCore(uiProvider, view)
    {}

    void ContainerViewCore::init()
    {
        ViewCore::init();

        ((BdnMacContainerView_ *)nsView()).viewCore = std::dynamic_pointer_cast<ContainerViewCore>(shared_from_this());
    }

    void ContainerViewCore::addChildView(std::shared_ptr<View> child)
    {
        if (auto childCore = child->core<ViewCore>()) {
            addChildNSView(childCore->nsView());
            _children.push_back(child);
        } else {
            throw std::runtime_error("Cannot add this type of View");
        }

        scheduleLayout();
    }

    void ContainerViewCore::removeChildView(std::shared_ptr<View> child)
    {
        if (auto childCore = child->core<ViewCore>()) {
            childCore->removeFromNsSuperview();
            _children.remove(child);
        } else {
            throw std::runtime_error("Cannot remove this type of View");
        }
        scheduleLayout();
    }

    std::list<std::shared_ptr<View>> ContainerViewCore::childViews() { return _children; }
}
