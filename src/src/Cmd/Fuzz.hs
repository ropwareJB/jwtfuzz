{-# LANGUAGE OverloadedStrings #-}
module Cmd.Fuzz
  (run) where

import           Data.Bifunctor
import           Data.Aeson
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Data.Text (Text)
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString.UTF8 as BS.UTF8
import qualified Data.ByteString.Base64.URL as B64
import           Data.ByteString (ByteString)
import Model.Args

run :: Args -> IO()
run args = do
  l <- getLine
  putStrLn . show . parseJwt $ BS.UTF8.fromString l

data Jwt =
  Jwt
    { head :: Object
    , body :: Object
    , tail :: ByteString
    }
  deriving (Show)

parseJwt :: ByteString -> Either Text Jwt
parseJwt s =
  case B.split (fromIntegral $ fromEnum '.') s of
    [head64,body64,tail64] -> do
      head_bs <- parseB64 head64
      body_bs <- parseB64 body64
      tail_bs <- parseB64 tail64

      head <- bimap T.pack id $ (eitherDecode (BSL.fromStrict head_bs) :: Either String Object)
      body <- bimap T.pack id $ (eitherDecode (BSL.fromStrict body_bs) :: Either String Object)

      Right $ Jwt head body tail_bs
    _ ->
      Left "Supplied String not conforming to <head>.<body>.<tail>"

parseB64 :: ByteString -> Either Text ByteString
parseB64 s =
  case B64.isBase64Url s of
    False ->
      Left "Provided ByteString is not a valid Base64 str"
    True ->
      B64.decodeBase64 s


