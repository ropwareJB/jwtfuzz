{-# LANGUAGE OverloadedStrings #-}
module Cmd.Fuzz
  (run) where

import qualified Data.ByteString as B
import qualified Data.ByteString.UTF8 as BS.UTF8
import           Data.ByteString (ByteString)
import Model.Args

run :: Args -> IO()
run args = do
  l <- getLine
  putStrLn . show . parseJwt $ BS.UTF8.fromString l

data Jwt =
  Jwt
    { head :: ByteString
    , body :: ByteString
    , tail :: ByteString
    }
  deriving (Show)

parseJwt :: ByteString -> Either String Jwt
parseJwt s =
  case B.split (fromIntegral $ fromEnum '.') s of
    [head,body,tail] ->
      Right $ Jwt head body tail
    _ ->
      Left "Supplied String not conforming to <head>.<body>.<tail>"
