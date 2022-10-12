{-# LANGUAGE DeriveDataTypeable #-}
module Model.Args
  (Args(..)) where

import           Data.Default
import           System.Console.CmdArgs

data Args =
  ArgsDefault
    { outputFile :: Maybe String
    }
  deriving (Show, Data, Typeable)

instance Data.Default.Default Args where
  def =
    ArgsDefault
      { outputFile = Nothing
      }
