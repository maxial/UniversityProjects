-- 1) Выражения

{-
   Вычислите с помощью ghci и сохраните в этом файле значения следующих выражений,
   обращая внимание на обозначения и приоритеты операций, стандартные функции,
   расстановку скобок:

    2 + 3
    mod 10 4
    10 `mod` 4
    True && 5 < 10
    5 < 7 || 10 > 3
    sqrt (-2)
    sqrt (sqrt 16)
    abs 5 + abs (-5)
    max 5 10
    let x = 4 in (sin x)^2 + (cos x)^2
    x
    let x = 4
    x
    7^(-1)
    pi/2
    undefined
    error "AAAA!!!!"
    12345^54321
    2 < 3 || 9999954321^99912345 > 12345^54321
    if not False then 1 else 0
    if not False then 1
    let b = if not False then 1 else 0
    b
   Пример оформления ответов:
   > 2 + 3
   5

-}

-- ghci> 2 + 3
-- 5
-- ghci> mod 10 4
-- 2
-- ghci> 10 `mod` 4
-- 2
-- ghci> True && 5 < 10
-- True
-- ghci> 5 < 7 || 10 > 3
-- True
-- ghci> sqrt (-2)
-- NaN
-- ghci> sqrt (sqrt 16)
-- 2.0
-- ghci> abs 5 + abs (-5)
-- 10
-- ghci> max 5 10
-- 10
-- ghci> let x = 4 in (sin x)^2 + (cos x)^2
-- 1.0
-- ghci> x
--
-- <interactive>:16:1: error: Variable not in scope: x
-- ghci> let x = 4
-- ghci> x
-- 4
-- ghci> 7^(-1)
-- *** Exception: Negative exponent
-- ghci> pi/2
-- 1.5707963267948966
-- ghci> undefined
-- *** Exception: Prelude.undefined
-- CallStack (from HasCallStack):
--   error, called at libraries/base/GHC/Err.hs:79:14 in base:GHC.Err
--   undefined, called at <interactive>:21:1 in interactive:Ghci17
-- ghci> error "AAAA!!!!"
-- *** Exception: AAAA!!!!
-- CallStack (from HasCallStack):
--   error, called at <interactive>:22:1 in interactive:Ghci17
-- ghci> 12345^54321
-- Segmentation fault: 11
-- ghci> 2 < 3 || 9999954321^99912345 > 12345^54321
-- True
-- ghci> if not False then 1 else 0
-- 1
-- ghci> if not False then 1
--
-- <interactive>:4:20: error:
--     parse error (possibly incorrect indentation or mismatched brackets)
-- ghci> let b = if not False then 1 else 0
-- ghci> b
-- 1

-- 2) Типы

{-
  Тип выражения можно узнать, воспользовавшись командой интерпретатора :t, например:

> :t 'a'
'a' :: Char
> :t 1
1 :: Num a => a

  Запись "1 :: Num a => a" означает, что выражение "1" имеет тип "a", где "a" принадлежит
  классу типов Num (имеет экземпляр класса типов Num, является числовым типом).

  Определите и сохраните в этом файле типы следующих выражений:
   5
   5.0
   '5'
   "5"
   abs 4
   abs 4.0
   sqrt 4
   sqrt 4.0
   max 4 9
   2 + 3
   5 < 7
   if 2 > 3 then 7 else 5
   5 > 6 && False
   pi

   Команда ":set +t" включает режим, при котором печатается тип каждого вычисляемого выражения.
   Команда ":set +s" включает режим, при котором печатается время вычисления каждого выражения.

-}

-- ghci> :t 5
-- 5 :: Num t => t
-- ghci> :t 5.0
-- 5.0 :: Fractional t => t
-- ghci> :t '5'
-- '5' :: Char
-- ghci> :t "5"
-- "5" :: [Char]
-- ghci> :t abs 4
-- abs 4 :: Num a => a
-- ghci> :t abs 4.0
-- abs 4.0 :: Fractional a => a
-- ghci> :t sqrt 4
-- sqrt 4 :: Floating a => a
-- ghci> :t sqrt 4.0
-- sqrt 4.0 :: Floating a => a
-- ghci> :t max 4 9
-- max 4 9 :: (Ord a, Num a) => a
-- ghci> :t 2 + 3
-- 2 + 3 :: Num a => a
-- ghci> :t 5 < 7
-- 5 < 7 :: Bool
-- ghci> :t if 2 > 3 then 7 else 5
-- if 2 > 3 then 7 else 5 :: Num t => t
-- ghci> :t 5 > 6 && False
-- 5 > 6 && False :: Bool
-- ghci> :t pi
-- pi :: Floating a => a
