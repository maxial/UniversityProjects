{-# LANGUAGE GADTs #-}

import Data.Monoid
import Data.Foldable

{-
   Это упражнение посвящено гауссовым целым числам. Всю необходимую информацию
   можно найти на соответствующей странице Википедии.
-}

data GaussInteger a = GI a a

-- 1. Определите экземпляры классов типов Eq и Show ("re + i*im") для типа GaussInteger.

-- ???

-- 2. Определите следующие операции:
plus :: Integral a => GaussInteger a -> GaussInteger a -> GaussInteger a
plus = undefined

mult :: Integral a => GaussInteger a -> GaussInteger a -> GaussInteger a
mult = undefined

norm :: Integral a => GaussInteger a -> a
norm = undefined

-- 3. Определите две обёртки (newtype) и напишите для обёрток два экземпляра
--    класса Monoid — для сложения и для умножения.

-- ???

{-
  4. Определите для  GaussInteger экземпляр класса типов Functor, соответствующий
     следующему примеру:

     ghci> fmap (+1) (GI 5 10)
     GI 6 11
-}

{-
  5. Реализуйте следующие функции:

sumGI :: Foldable t => t (GaussInteger a) -> GaussInteger a
sumGI = undefined . fold . undefined

productGI :: Foldable t => t (GaussInteger a) -> GaussInteger a
productGI = undefined . fold . undefined
-}
