#:___________________________________________________________
#  cvulkan  |  Copyright (C) Ivan Mar (sOkam!)  |  MPL-2.0  :
#:___________________________________________________________
import std/os
import futhark
importc:
  path currentSourcePath.parentDir/"src"/"cvulkan"/"C"/"src"
  outputPath currentSourcePath.parentDir/"src"/"cvulkan"/"raw.nim"
  "cvulkan.h"
