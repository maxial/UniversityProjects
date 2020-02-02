{-
  1. Определите экземпляр класса Functor для бинарного дерева, в каждом узле которого
  хранятся элементы типа Maybe.

  Определённый экземпляр должен соответствовать следующим примерам:

    ghci> words <$> Leaf Nothing
    Leaf Nothing

    ghci> words <$> Leaf (Just "a b")
    Leaf (Just ["a","b"])
-}

data Tree a = Leaf (Maybe a) | Branch (Tree a) (Maybe a) (Tree a) deriving Show

-- instance ???
