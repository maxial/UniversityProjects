{-# LANGUAGE OverloadedStrings #-}

-- Версия на Data.Text

import System.Environment
import qualified Data.Text as T
import Data.Text.Read
import qualified Data.Text.IO as TIO

oneLine :: T.Text -> T.Text
oneLine xs = T.concat [before, "+", after, "=", res]
  where
    [before, after] = T.splitOn "," xs
    Right (n1, "") = signed decimal before
    Right (n2, "") = signed decimal after
    res = T.pack $ show $ n1 + n2

allLines :: T.Text -> T.Text
allLines = T.unlines . map oneLine . T.lines

main = do
  [inf, outf] <- getArgs
  allLines <$> TIO.readFile inf >>= TIO.writeFile outf
