{-# LANGUAGE OverloadedStrings #-}
module Model.Jwt
  ( Jwt(..)
  , parseJwt
  ) where

import           Data.Aeson
import           Data.Bifunctor
import qualified Data.ByteString as B
import qualified Data.ByteString.UTF8 as BS.UTF8
import qualified Data.ByteString.Base64.URL as B64
import qualified Data.ByteString.Lazy as BSL
import           Data.ByteString (ByteString)
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T

data Jwt =
  Jwt
    { jwtHead :: Object
    , jwtBody :: Object
    , jwtTail :: ByteString
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

