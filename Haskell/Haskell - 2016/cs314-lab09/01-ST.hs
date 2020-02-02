-- Пользуясь средствами монады ST, запрограммируйте любой алгоритм сортировки массива.

import Data.STRef
import Control.Monad.ST

import Data.Array
import Data.Array.ST
import Data.Array.MArray

swapElems :: Ix i => i -> i -> STArray s i e -> ST s ()
swapElems i j arr = do
     vi <- readArray arr i
     vj <- readArray arr j
     writeArray arr i vj
     writeArray arr j vi

test :: Int -> Int -> [a] -> [a]
test i j xs = elems $ runSTArray $ do
    arr <- newListArray (0, length xs - 1) xs
    swapElems i j arr
    return arr

mysort :: [a] -> [a]
mysort = undefined
