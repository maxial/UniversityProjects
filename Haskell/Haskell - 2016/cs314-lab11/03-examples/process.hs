-- Простейшая реализация
import System.Environment

oneLine :: String -> String
oneLine xs = concat [before, "+", after, "=", res]
  where
    (before, (_ : after)) = break (==',') xs
    n1 = read before
    n2 = read after
    res = show $ n1 + n2

allLines :: String -> String
allLines = unlines . map oneLine . lines

main = do
  [inf, outf] <- getArgs
  allLines <$> readFile inf >>= writeFile outf
