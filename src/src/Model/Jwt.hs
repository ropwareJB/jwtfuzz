{-# LANGUAGE OverloadedStrings #-}
module Model.Jwt
  ( Jwt(..)
  , parseJwt
  , toString
  , insertHeader
  , insertClaim
  , upsertAlgo
  , deleteClaimHead
  ) where

import           Data.Aeson
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.Aeson.Key as Key
import           Data.Bifunctor
import qualified Data.ByteString as B
import qualified Data.ByteString.UTF8 as BS.UTF8
import qualified Data.ByteString.Base64.URL as B64url
import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString.Lazy.UTF8 as BSL.UTF8
import           Data.ByteString (ByteString)
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Text.Printf

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
      head_bs <- parseB64url head64
      body_bs <- parseB64url body64
      tail_bs <- parseB64url tail64

      head <- bimap T.pack id $ (eitherDecode (BSL.fromStrict head_bs) :: Either String Object)
      body <- bimap T.pack id $ (eitherDecode (BSL.fromStrict body_bs) :: Either String Object)

      Right $ Jwt head body tail_bs
    _ ->
      Left "Supplied String not conforming to <head>.<body>.<tail>"

parseB64url :: ByteString -> Either Text ByteString
parseB64url s =
  case B64url.isBase64Url s of
    False ->
      Left "Provided ByteString is not a valid Base64 str"
    True ->
      B64url.decodeBase64 s

toString :: Jwt -> String
toString jwt =
  printf "%s.%s.%s"
    (B64url.encodeBase64Unpadded . BSL.toStrict . encode $ jwtHead jwt)
    (B64url.encodeBase64Unpadded . BSL.toStrict . encode $ jwtBody jwt)
    (B64url.encodeBase64 $ jwtTail jwt)

insertHeader :: Jwt -> (String, String) -> Jwt
insertHeader jwt (k,v) =
  jwt { jwtHead = KeyMap.insert (Key.fromString k) (Data.Aeson.String $ T.pack v) (jwtHead jwt) }

insertClaim :: Jwt -> (String, String) -> Jwt
insertClaim jwt (k,v) =
  jwt { jwtBody = KeyMap.insert (Key.fromString k) (Data.Aeson.String $ T.pack v) (jwtBody jwt) }

upsertAlgo :: Jwt -> String -> Jwt
upsertAlgo jwt alg =
  jwt { jwtHead = KeyMap.insert (Key.fromString "alg") (Data.Aeson.String $ T.pack alg) (jwtHead jwt) }

deleteClaimHead :: Jwt -> String -> Jwt
deleteClaimHead jwt claimKey =
  jwt { jwtHead = KeyMap.delete (Key.fromString claimKey) (jwtHead jwt) }
