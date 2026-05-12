import type { RNPackageContext, RNPackage } from "@rnoh/react-native-openharmony";
import { PushyPackage } from "pushy";
import { AuthPackage } from "lib_rn";

export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [
    new PushyPackage(ctx),
    new AuthPackage(ctx),
  ];
}
