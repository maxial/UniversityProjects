{-# LANGUAGE OverloadedStrings #-}

-- Версия с контролем корректности (Either) и игнорированием ошибок формата

import System.Environment
import qualified Data.Text as T
import Data.Text.Read
import qualified Data.Text.IO as TIO
import Data.Either

oneLine :: T.Text -> Either String T.Text
oneLine xs = check $ T.splitOn "," xs
  where
    check xs@[before, after]
      = (\res -> T.concat [before, "+", after, "=", res]) . T.pack . show . sum
        <$> mapM parseNumber xs
    check _ = Left "line has incorrect format"

    parseNumber s
      | Right (res, "") <- decimal s = Right res
    parseNumber _ = Left "incorrect numeric format"


allLines :: T.Text -> T.Text
allLines = T.unlines . map (\(Right s) -> s) . filter isRight . map oneLine . T.lines

main = do
  [inf, outf] <- getArgs
  allLines <$> TIO.readFile inf >>= TIO.writeFile outf
