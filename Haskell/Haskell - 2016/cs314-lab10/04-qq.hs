{- Разработайте QuasiQuoter, который делает данный файл компилируемым. -}

{-# LANGUAGE QuasiQuotes #-}

import Worder

data Name = Name String String

list2Name :: [String] -> Name
list2Name [x, y] = Name x y

namesDB :: [Name]
namesDB = map list2Name [wrds|Иванов Иван
                              Петров Петр
                              Сидорова Мария
                              Козлов Константин |]
