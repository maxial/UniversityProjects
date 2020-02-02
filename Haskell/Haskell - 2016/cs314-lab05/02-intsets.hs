{-
  В параметрах командной строки указаны имена нескольких текстовых файлов,
  содержащих целые числа, разделённые пробелами и символами перевода строк.
  Пользуясь множествами, определить:
  A) какие и сколько чисел содержатся в каждом из данных файлов (пересечение);
  B) какие и сколько чисел содержатся хотя бы в одном из данных файлов (объединение).
-}

import System.Environment

readNumFile :: FilePath -> IO [Int]
readNumFile = undefined

readAllFiles :: [String] -> IO [[Int]]
readAllFiles = mapM readNumFile

solveA, solveB :: [[Int]] -> (Int, [Int])
solveA = undefined
solveB = undefined

main = do
  args <- getArgs
  xss <- readAllFiles args
  print $ solveA xss
  print $ solveB xss
