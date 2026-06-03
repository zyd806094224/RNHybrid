#ifndef AUTH_TURBOMODULE_H
#define AUTH_TURBOMODULE_H

#include <ReactCommon/TurboModule.h>
#include "RNOH/ArkTSTurboModule.h"

namespace rnoh {
class JSI_EXPORT AuthTurboModule : public ArkTSTurboModule {
public:
    AuthTurboModule(const ArkTSTurboModule::Context ctx, const std::string name);
};
} // namespace rnoh

#endif
