#include "AuthTurboModule.h"

using namespace rnoh;
using namespace facebook;

static jsi::Value _hostFunction_AuthTurboModule_onTokenExpired(
    jsi::Runtime &rt,
    react::TurboModule &turboModule,
    const jsi::Value *args,
    size_t count)
{
    // JS resolves Harmony AuthModule through TurboModuleRegistry. This C++
    // host function forwards the call into the ArkTS UITurboModule method.
    return jsi::Value(static_cast<ArkTSTurboModule &>(turboModule).call(rt, "onTokenExpired", args, count));
}

AuthTurboModule::AuthTurboModule(const ArkTSTurboModule::Context ctx, const std::string name)
    : ArkTSTurboModule(ctx, name)
{
    methodMap_["onTokenExpired"] = MethodMetadata{0, _hostFunction_AuthTurboModule_onTokenExpired};
}
