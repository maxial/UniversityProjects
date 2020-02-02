{-
   Тип Parser может быть определён следуюшим образом:
-}

import Control.Applicative
import Control.Monad

newtype Parser a = Parser { apply :: String -> Maybe (a, String) }

{-
   Определите экземпляры классов Functor, Applicative, Alternative, Monad и MonadPlus
   для типа Parser в этом случае:
-}

instance Functor Parser where
  fmap f = undefined

instance Applicative Parser where
  pure a = undefined
  p <*> q = undefined

instance Alternative Parser where
  empty = undefined
  p <|> q = undefined

instance Monad Parser where
  return x = undefined
  p >>= q = undefined
  fail _ = undefined

instance MonadPlus Parser where
  mzero = undefined
  p `mplus` q = undefined
