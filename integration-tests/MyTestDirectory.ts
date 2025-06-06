// Note: This file is autogenerated. Do not edit it directly.
//
// Describes the contents of the test directory, which is a blueprint for
// files and directories. Tests can create a unique, safe environment for
// interacting with the contents of such a directory.
//
// Having strong typing for the test directory contents ensures that tests can
// be written with confidence that the files and directories they expect are
// actually found. Otherwise the tests are brittle and can break easily.

import { z } from "zod"

export const MyTestDirectorySchema = z.object({
  name: z.literal("test-environment/"),
  type: z.literal("directory"),
  contents: z.object({
    ".config": z.object({
      name: z.literal(".config/"),
      type: z.literal("directory"),
      contents: z.object({}),
    }),
    ".gitconfig": z.object({
      name: z.literal(".gitconfig"),
      type: z.literal("file-symlink"),
      target: z.literal("../../.gitconfig"),
    }),
  }),
})

export const MyTestDirectoryContentsSchema =
  MyTestDirectorySchema.shape.contents
export type MyTestDirectoryContentsSchemaType = z.infer<
  typeof MyTestDirectorySchema
>

export type MyTestDirectory = MyTestDirectoryContentsSchemaType["contents"]

export const testDirectoryFiles = z.enum([".config", ".gitconfig", "."])
export type MyTestDirectoryFile = z.infer<typeof testDirectoryFiles>
