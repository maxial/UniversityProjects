{-# LANGUAGE TypeFamilies, MultiParamTypeClasses, InstanceSigs #-}

{- Реализуйте все необходимые экземпляры класса GNum,
   чтобы этот файл стал компилируемым. -}

class GNum a b where
  type SumTy a b :: *
  (+++) :: a -> b -> SumTy a b


test = (a +++ k) +++ (n +++ z) 
  where
    a = 1.5 :: Double
    k = 5 :: Int
    n = 100 :: Integer
    z = 0.1 :: Float
