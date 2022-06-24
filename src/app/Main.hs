module Main where

import System.Console.CmdArgs
import Lib
import Model.Args

cmdDefault :: Args
cmdDefault =
  ArgsDefault
    {
    } &= name "fuzz"

mode :: Mode (CmdArgs Args)
mode = cmdArgsMode $ modes
    [ cmdDefault
    ]
  &= help "JwtFuzz"
  &= program "jwtfuzz"
  &= summary "\nv0.0.1, 2022 ROPWARE, Joshua Brown"

main :: IO ()
main = do
  opts <- cmdArgsRun mode
  process opts

