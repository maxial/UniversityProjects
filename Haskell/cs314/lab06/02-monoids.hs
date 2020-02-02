-- 1. Реализуйте instance Monoid для типа Xor, в котором mappend выполняет операцию xor.

newtype Xor = Xor { getXor :: Bool }
    deriving (Eq,Show)

instance Monoid Xor where
    mempty = undefined
    mappend = undefined

{-
  2. Реализуйте instance Monoid для Maybe' a так, чтобы mempty не был равен Maybe' Nothing.
  Нельзя накладывать никаких дополнительных ограничений на тип a, кроме указанных в условии.
-}

newtype Maybe' a = Maybe' { getMaybe :: Maybe a }
    deriving (Eq,Show)

instance Monoid a => Monoid (Maybe' a) where
    mempty = undefined
    mappend = undefined
