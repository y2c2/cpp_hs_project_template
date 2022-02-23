-- Lib1.hs
module Lib1 where

import Foreign.C.Types

foreign export ccall add2 :: CInt -> CInt -> CInt

add2 :: CInt -> CInt -> CInt
add2 a b = a + b

