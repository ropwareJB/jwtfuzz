{-# LANGUAGE OverloadedStrings #-}
module Cmd.Fuzz
  (run) where

import           Data.Aeson
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BS.UTF8
import           Data.Either
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
  -- TODO
  []

atk_nullInj :: Jwt -> [Jwt]
atk_nullInj jwt =
  -- TODO
  []

atk_psychicSig :: Jwt -> [Jwt]
atk_psychicSig jwt =
  -- TODO: Psychic Signatures
  -- https://github.com/DataDog/security-labs-pocs/tree/main/proof-of-concept-exploits/jwt-null-signature-vulnerable-app
  -- https://neilmadden.blog/2022/04/19/psychic-signatures-in-java/
  []

-- IssuedAt
atk_iat :: Jwt -> [Jwt]
atk_iat jwt =
  -- TODO
  []

-- NotBefore nbf
atk_notBefore :: Jwt -> [Jwt]
atk_notBefore jwt =
  -- TODO
  []

-- Expiry
atk_exp :: Jwt -> [Jwt]
atk_exp jwt =
  -- TODO
  []


atk_removeAlg :: Jwt -> [Jwt]
atk_removeAlg jwt =
  -- TODO
  []

atk_removeType :: Jwt -> [Jwt]
atk_removeType jwt =
  -- TODO
  []

atk_removeSig :: Jwt -> [Jwt]
atk_removeSig jwt =
  [ jwt { jwtTail = BS.empty } ]

atk_emptyHeader :: Jwt -> [Jwt]
atk_emptyHeader jwt =
  [ jwt { jwtHead = KeyMap.empty } ]

atk_emptyPayload :: Jwt -> [Jwt]
atk_emptyPayload jwt =
  [ jwt { jwtBody = KeyMap.empty } ]

