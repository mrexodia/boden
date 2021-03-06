#include <bdn/android/AttributedString.h>
#include <bdn/android/wrapper/Build.h>
#include <bdn/android/wrapper/Html.h>

#include <bdn/log.h>

namespace bdn::android
{
    AttributedString::AttributedString() : _spanned(bdn::java::Reference()) {}

    bool AttributedString::fromHTML(const String &html)
    {
        if ((int)wrapper::Build::VERSION::SDK_INT >= wrapper::Build::VERSION_CODES::M) {
            _spanned = wrapper::Html::fromHTMLWithFlags(html, wrapper::Html::FROM_HTML_MODE_COMPACT);
        } else {
            _spanned = wrapper::Html::fromHTML(html);
        }

        return true;
    }

    String AttributedString::toHTML() const
    {
        if ((int)wrapper::Build::VERSION::SDK_INT > wrapper::Build::VERSION_CODES::M) {
            return wrapper::Html::toHTMLWithFlags(_spanned, wrapper::Html::TO_HTML_PARAGRAPH_LINES_INDIVIDUAL);
        } else {
            return wrapper::Html::toHTML(_spanned);
        }
    }
}

namespace bdn
{
    std::function<std::shared_ptr<AttributedString>()> AttributedString::defaultCreateAttributedString()
    {
        return []() -> std::shared_ptr<AttributedString> { return std::make_shared<bdn::android::AttributedString>(); };
    }
}
