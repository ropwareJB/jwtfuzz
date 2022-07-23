{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( process
    ) where

import           Foreign.C.String
import           Foreign.Ptr
import           Foreign.ForeignPtr
import qualified Cmd.Fuzz
import           Model.Args
import           Model.Jwt as Jwt
import           Text.Printf

foreign export ccall fuzzJwt :: String -> IO()

process :: Args -> IO ()
process args = do
  case args of
    ArgsDefault{} -> do
      l <- getLine
      jwts <- Cmd.Fuzz.run args l
      mapM_ (printf "%s\n" . Jwt.toString) $ jwts

fuzzJwt :: String -> IO ()
fuzzJwt jwt = do
  jwts <- Cmd.Fuzz.run (ArgsDefault{}) jwt
  mapM_ (printf "%s\n" . Jwt.toString) $ jwts
