import packageConfig from "@mikavilpas/oxfmt-config"
import { defineConfig } from "oxfmt"

export default defineConfig({
  ...packageConfig,
  ignorePatterns: ["integration-tests/dist/", "pnpm-lock.yaml", ".repro", "CHANGELOG.md"],
})
