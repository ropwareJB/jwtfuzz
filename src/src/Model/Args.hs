{-# LANGUAGE DeriveDataTypeable #-}
module Model.Args
  (Args(..)) where

import           System.Console.CmdArgs

data Args =
  ArgsDefault
    {}
  deriving (Show, Data, Typeable)

