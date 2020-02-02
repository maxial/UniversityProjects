{-# LANGUAGE TypeFamilies,MultiParamTypeClasses,InstanceSigs #-}

import Data.Set
import Data.Sequence


class GNum a b where
  type SumTy a b :: *
  plus :: a -> b -> SumTy a b

instance GNum Int Int where
  type SumTy Int Int = Int
  plus a b = a + b

instance GNum Int Double where
  type SumTy Int Double = Double
  plus a b = fromIntegral a + b





class Foo a where
  data family T a  
  foo :: T a -> Int
instance Foo Int where
  data T Int  = A  
  foo A = undefined
instance Foo Char where
  data T Char = B
  foo B = undefined

type family Elem c :: *

type instance Elem [e] = e  

type instance Elem (Set a) = a

type instance Elem (Seq a) = a
