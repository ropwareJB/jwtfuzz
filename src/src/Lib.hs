{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( process
    , fuzzJwt_c
    ) where

import           Data.Either
import           Foreign.C.String
import           Foreign.Ptr
import           Foreign.Storable
import           Foreign.Marshal.Array
import           Foreign.ForeignPtr
import qualified Cmd.Fuzz
import           Model.Args
import           Model.Jwt as Jwt
import           Text.Printf

foreign export ccall "fuzzjwt_fuzz" fuzzJwt_c :: Ptr CString -> CString -> IO (Ptr CString)

process :: Args -> IO ()
process args = do
  case args of
    ArgsDefault{} -> do
      l <- getLine
      jwts_e <- Cmd.Fuzz.run args l
      printJwts jwts_e

-- Take in a (Ptr CString) to capture any error message.
-- Will return a null-terminated list of char*
fuzzJwt_c :: Ptr CString -> CString -> IO (Ptr CString)
fuzzJwt_c ptr_err jwt_cstr = do
  jwt <- peekCString jwt_cstr
  jwts_e <- Cmd.Fuzz.run (ArgsDefault{}) jwt
  case jwts_e of
    Left e -> do
      poke ptr_err =<< newCString e
      newArray0 nullPtr . return  =<< newCString ""
    Right jwts ->
      newArray0 nullPtr =<< mapM (newCString . Jwt.toString) jwts

printJwts :: Either String [Jwt] -> IO()
printJwts (Left err) = printf "%s\n" err
printJwts (Right jwts) = mapM_ (printf "%s\n" . Jwt.toString) $ jwts
