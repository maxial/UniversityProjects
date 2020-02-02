{-# LANGUAGE EmptyDataDecls #-}

import System.Environment
import Data.List
import Data.Char

{-
  Разработайте тип данных User для хранения следующей информации:
   * ID пользователя (целое число)
   * Имя пользователя
   * Пароль пользователя
   * Вес пользователя (вещественное число, но информация может отсутствовать)
-}

data User = User {
   idd :: Int
   , name :: String
   , pass :: String
   , weight :: Double} deriving (Show)

{-
   Реализуйте функцию, которая по списку, содержащему 3 или 4 строки, возвращает
   значение типа User. Если список содержит иное количество строк, должна
   вызываться функция error.
-}

str2user :: [String] -> User
str2user ss 
    | length ss < 3 || length ss > 4 = error "wrong args"
    | length ss == 3 = User {idd=(read(ss!!0)::Int), name=(ss!!1),pass=(ss!!2),weight=0}
    | length ss == 4 = User {idd=(read(ss!!0)::Int), name=(ss!!1),pass=(ss!!2),weight=(read(ss!!3)::Double)}
    | otherwise = error "wrong args"

{-
   Реализуйте функцию, которая загружает из файла с заданным именем
   список пользователей. Формат файла: ID ИМЯ ПАРОЛЬ ВЕС
   Для тестирования используйте файл data1.txt.
-}

loadData :: FilePath -> IO [User]
loadData fname = do
  content <- readFile fname
  let contents = lines content
      users = map (\s -> str2user $ words s) contents
  return users

{-
   Напишите функции, которые по заданному списку пользователей находят следующую
   информацию:
   * Отчёт 1: количество пользователей, вес которых больше 100.
   * Отчёт 2: наименьший и наибольший ID
   * Отчёт 3: средний вес всех пользователей с известным весом
   * Отчёт 4: список имён пользователей с паролями максимальной длины
   * Отчёт 5: список количеств пользователей с именами длиной 1, 2, 3 и т.д. символов
   * Отчёт 6: наиболее часто используемая в паролях буквенная триграмма
              (последовательность из трёх букв) без учёта регистра

   Каждый отчёт оценивается в 1 балл. Явная рекурсия в отчётах не допускается,
   следует использовать функции высших порядков. Заведомо неэффективные решения
   не засчитываются.
-}

report1 :: [User] -> Int
report1 users = foldl (\z w -> if (w > 100) then z+1 else z) 0 (map (\u -> weight u) users)

report2 :: [User] -> IO ()
report2 users = do
  let ids = map (\u -> idd u) users
      minid = minimum ids
      maxid = maximum ids
  putStrLn ("Min id: " ++ show minid)
  putStrLn ("Max id: " ++ show maxid)
  
report3 :: [User] -> Double
report3 users = 
  let 
    weights = filter (/=0) (map (\u -> weight u) users)
  in
    (sum weights) / fromIntegral(length weights)

report4 :: [User] -> IO ()
report4 users = do
  let names = sortBy (\(x,y) (a,b) -> a `compare` x) (map (\u -> (length $ pass u, name u)) users)
      maxpass = fst(head names)
      neednames = takeWhile (\(x,y) -> x == maxpass) names
  print neednames
  
report5 :: [User] -> IO ()
report5 users = do
  let nameslen = group $ sort (map (\u -> length $ name u) users)
      need = map (\s -> (head s, length s)) nameslen
  print need
  
getTrigrams :: String -> [String]
getTrigrams s | length s < 3 = []
              | otherwise = take 3 s : getTrigrams (drop 1 s)
  
report6 :: [User] -> IO ()
report6 users = do
  let passes = map (\u -> map toLower $ pass u) users
      trigrams = sort $ concatMap getTrigrams passes
      need = foldl (\(z,l) (x,y) -> if (y>l) then (x,y) else (z,l)) ("",0) $ 
             map (\s -> (head s,length s)) $ group trigrams
  print need

{-
   Напишите основную программу, которая читает параметр командной строки --- имя файла,
   загружает из него список пользователей и печатает отчёты 1-6.

   Объявление типа User и корректная загрузка данных из файла в список [User]
   оцениваются в 2 балла.
-}

main = do
  putStr "Input file name: "
  fname <- getLine
  users <- loadData fname
  print $ report1 users
  report2 users
  print $ report3 users
  report4 users
  report5 users
  report6 users