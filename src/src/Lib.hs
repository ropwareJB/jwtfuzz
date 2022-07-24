{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( process
    , fuzzJwt_c
    ) where

import           Foreign.C.String
import           Foreign.Ptr
import           Foreign.ForeignPtr
import qualified Cmd.Fuzz
import           Model.Args
import           Model.Jwt as Jwt
import           Text.Printf

foreign export ccall "fuzzJwt" fuzzJwt_c :: CString -> IO()

process :: Args -> IO ()
process args = do
  case args of
    ArgsDefault{} -> do
      l <- getLine
      jwts <- Cmd.Fuzz.run args l
      printJwts jwts

fuzzJwt_c :: CString -> IO()
fuzzJwt_c jwt_cstr = peekCString jwt_cstr >>= fuzzJwt

fuzzJwt :: String -> IO ()
fuzzJwt jwt = do
  jwts <- Cmd.Fuzz.run (ArgsDefault{}) jwt
  printJwts jwts

printJwts :: [Jwt] -> IO()
printJwts jwts = mapM_ (printf "%s\n" . Jwt.toString) $ jwts
