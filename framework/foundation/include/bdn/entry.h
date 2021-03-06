#pragma once

#include <bdn/Application.h>

namespace bdn
{
    /**
     * @brief Marks the beginning of an entry function, i.e. a place where the
     * operating system passes control to the App.
     * @param function The function to call
     * @param canKeepRunningAfterException If true, application can continue to
     * run if an exception was caught
     * @param platformSpecific See notes
     *
     * This function is used to wrap our code whenever the operating system
     * calls into our process. If an exception is caught \ref
     * bdn::unhandledException will be called.
     *
     * \note On Android the platformSpecific parameter is a pointer to the
     * JNIEnv object that the JNI function received from the Java side.
     */
    void platformEntryWrapper(const std::function<void()> &function, bool canKeepRunningAfterException,
                              void *platformSpecific = nullptr);

    template <typename RETURN_TYPE>
    RETURN_TYPE nonVoidPlatformEntryWrapper(std::function<RETURN_TYPE()> function, bool canKeepRunningAfterException,
                                            void *platformSpecific = nullptr)
    {
        RETURN_TYPE returnValue;

        platformEntryWrapper([&returnValue, &function]() { returnValue = function(); }, canKeepRunningAfterException,
                             platformSpecific);

        return returnValue;
    }
}
