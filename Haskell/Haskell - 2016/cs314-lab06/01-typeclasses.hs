{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

{-
   Класс типов Binary предназначен для получения явного
   двоичного представления некоторого типа данных.
-}

class Binary a where
  toBinary :: a -> [Bool]
  fromBinary :: [Bool] -> Maybe a

{-
   1. Реализуйте экземпляры класса типов Binary для следующих типов:
      * Integer
      * Char
      * Bool
      * [Bool]
      * String
-}

{-
   2. Определите класс типов Listable с двумя функциями:
   toList :: a -> [a]
   fromList :: [a] -> a
-}

{-
  3. Объявите экземпляры класса типов Listable для следующих типов:
     * String - строка разбивается по пробелам на список слов.
     * Integer - любое целое число разбивается на список цифр.
-}
