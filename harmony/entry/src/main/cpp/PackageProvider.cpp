#include "RNOH/PackageProvider.h"
#include "PushyPackage.h"
#include "AuthPackage.h"

using namespace rnoh;

std::vector<std::shared_ptr<Package>> PackageProvider::getPackages(Package::Context ctx) {
    return {
        std::make_shared<PushyPackage>(ctx),
        // Provides AuthModule for RN token-expired callbacks.
        std::make_shared<AuthPackage>(ctx)
    };
}
