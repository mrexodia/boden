#pragma once

#include <bdn/ViewCore.h>

namespace bdn
{
    class ButtonCore
    {
        friend class Button;

      public:
        using ClickCallback = std::function<void()>;

      public:
        Property<String> label;

      public:
        virtual ~ButtonCore() = default;

      protected:
        WeakCallback<void()> _clickCallback;
    };
}
