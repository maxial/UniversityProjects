{-# LANGUAGE EmptyDataDecls #-}
{-
  Написать программу, работа которой управляется конфигурационным файлом,
  содержащим строки следующего формата:
    имя поля=значение
  Возможными именами полей являются summand (слагаемое), multiplier (множитель),
  divisor (делитель). Все значения являются целыми числами. В качестве параметров
  командной строки программе подаются имя конфигурационного файла и имя текстового
  файла с целочисленными данными. Над каждым целым числом из второго файла выполняются
  операции, указанные в конфигурационном файле, то есть число складывается,
  умножается и делится соответственно. Если какое-либо поле отсутствует, то действие
  не выполняется. Результаты вычислений выводятся на консоль.

  Необходимо организовать доступ к параметрам конфигурационного файла средствами
  монады Reader.
-}

import Control.Monad.Reader

data Config

loadConfig :: FilePath -> IO Config
loadConfig = undefined

loadData :: FilePath -> IO [Int]
loadData = undefined

-- cruncher :: ???
cruncher = undefined

main = do
  undefined
  config <- loadConfig undefined
  numbers <- loadData undefined
  let results = runReader (cruncher numbers) config :: [Int]
  mapM_ print results
