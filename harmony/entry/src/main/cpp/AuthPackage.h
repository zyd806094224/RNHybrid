#ifndef AUTH_PACKAGE_H
#define AUTH_PACKAGE_H

#include "RNOH/Package.h"
#include "AuthTurboModule.h"

using namespace rnoh;
using namespace facebook;

class AuthTurboModuleFactoryDelegate : public TurboModuleFactoryDelegate {
public:
    SharedTurboModule createTurboModule(Context ctx, const std::string &name) const override
    {
        // Harmony RNOH custom native modules must be registered on the C++
        // side before JS can resolve them through TurboModuleRegistry.
        if (name == "AuthModule") {
            return std::make_shared<AuthTurboModule>(ctx, name);
        }
        return nullptr;
    }
};

namespace rnoh {
class AuthPackage : public Package {
public:
    AuthPackage(Package::Context ctx) : Package(ctx) {}

    std::unique_ptr<TurboModuleFactoryDelegate> createTurboModuleFactoryDelegate() override
    {
        return std::make_unique<AuthTurboModuleFactoryDelegate>();
    }
};
} // namespace rnoh

#endif
