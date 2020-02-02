{-
  Пользуясь расширением TemplateHaskell, реализуйте следующие
  возможности для обработки любых кортежей размерами от 2 до 100:

  1) replicateT :: n -> a -> (a, ..., a)
     где в результирующем кортеже n компонентов;

  2) applyT :: n -> (a1->b1, a2->b2, ..., a1->bn) -> (a1,a2,...,an) -> (b1,b2,...,bn)

-}

{-# LANGUAGE TemplateHaskell #-}


-- Должно быть True
test1 = let t = (1, 2, 3) in $(applyT 3) ($(replicateT 3) id) t == t
test2 = let t = (1, True, "xxx") in $(applyT 3) ($(replicateT 3) id) t == t
