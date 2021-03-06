#pragma once

#include <bdn/ui/Label.h>

#import <bdn/mac/ViewCore.hh>
#import <bdn/mac/util.hh>

namespace bdn::ui::mac
{
    class LabelCore : public ViewCore, virtual public Label::Core
    {
      public:
        LabelCore(const std::shared_ptr<ViewCoreFactory> &viewCoreFactory);

      public:
        Size sizeForSpace(Size availableSpace) const override;
        float calculateBaseline(Size forSize, bool forIndicator) const override;

      private:
        void textPropertyChanged(const Text &text);

      private:
        NSTextView *_nsTextView;
        bool _wrap;
    };
}
