{-# LANGUAGE OverloadedStrings #-}

-- Версия с контролем корректности (исключения) и прерыванием обработки
-- с выводом сообщения об ошибке

import System.Environment
import qualified Data.Text as T
import Data.Text.Read
import qualified Data.Text.IO as TIO
import Control.Exception
import Data.Typeable

data FormatException = IncorrectLineFormat | IncorrectNumericFormat
                       deriving (Show, Typeable)

instance Exception FormatException

oneLine :: T.Text -> T.Text
oneLine xs = check $ T.splitOn "," xs
  where
    check xs@[before, after]
      = (\res -> T.concat [before, "+", after, "=", res]) . T.pack . show . sum
        $ map parseNumber xs
    check _ = throw IncorrectLineFormat

    parseNumber s
      | Right (res, "") <- decimal s = res
    parseNumber _ = throw IncorrectNumericFormat


allLines :: T.Text -> T.Text
allLines = T.unlines . map oneLine . T.lines

main = do
  [inf, outf] <- getArgs
  (allLines <$> TIO.readFile inf >>= TIO.writeFile outf) `catch` \e -> do
    print (e :: FormatException)
