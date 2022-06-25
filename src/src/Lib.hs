{-# LANGUAGE OverloadedStrings #-}
module Lib
    ( process
    ) where

import qualified Cmd.Fuzz
import Model.Args

process :: Args -> IO ()
process args = do
  case args of
    ArgsDefault{} ->
      Cmd.Fuzz.run args

