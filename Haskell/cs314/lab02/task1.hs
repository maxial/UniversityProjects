{-
 1) Вычислить сумму всех целых чисел от a до b включительно (a<=b).
    Требуется написать два решения: рекурсивное и итеративное
    (с аккумулирующим параметром). Необходимо предусмотреть случай
    некорректных значений параметров a и b.
-}

sum_ab_rec :: Int -> Int -> Int
sum_ab_rec a b
    | a > b = 0
    | a == b = a
    | otherwise = a + sum_ab_rec (a + 1) b

sum_ab_iter :: Int -> Int -> Int
sum_ab_iter a b = iter a b 0
    where iter a b acc
            | a > b = 0
            | a == b = acc + a
            | otherwise = iter (a + 1) b (acc + a)

-- 2) Определить рекурсивную функцию, определяющую количество чётных
--    элементов в списке.

nEven :: Integral a => [a] -> Int
nEven [] = 0
nEven (x:xs) = (if even x then 1 else 0) + nEven xs

{-
 3) Увеличить все элементы заданного списка в два раза с помощью рекурсии.
    Указание: в решении может понадобиться операция конструирования списка
    (присоединение головы к хвосту):

   ghci> 1 : [2,3,4]
   [1,2,3,4]
-}

doubleElems :: Num a => [a] -> [a]
doubleElems [] = []
doubleElems (x:xs) = x * 2 : doubleElems xs

{-
 4) Дан список целых чисел. Пользуясь рекурсией, сформировать новый
    список, содержащий только нечётные элементы исходного.
    Совет: в решении может пригодиться функция odd.
-}

fltOdd :: Integral a => [a] -> [a]
fltOdd [] = []
fltOdd (x:xs) = if odd x then x : fltOdd xs else fltOdd xs

{-
 5) Написать рекурсивную функцию repl, которая по заданному целому
    числу n и параметру произвольного типа a создаёт список длины n,
    содержащий элементы a.
-}

repl :: Int -> a -> [a]
repl 0 _ = []
repl n a
    | n < 0 = []
    | otherwise = a : repl (n - 1) a

{-
 6) Написать рекурсивную функцию, которая принимает на вход функцию и список,
    применяет функцию к каждому элементу списка и возвращает список
    результатов.
-}

processList :: (a -> a) -> [a] -> [a]
processList _ [] = []
processList f (x:xs) = f x : processList f xs

-- Написать вторую реализацию функции doubleElems с использованием processList
-- (левую часть определения менять нельзя)

doubleElems' :: Num a => [a] -> [a]
doubleElems' = processList (*2)

{-
 7) Написать рекурсивную функцию, которая принимает на вход предикат
    (функцию, возвращающую Bool) и список, и возвращает список,
    содержащий только удовлетворяющие предикату элементы.
-}

filterPred :: (a -> Bool) -> [a] -> [a]
filterPred _ [] = []
filterPred p (x:xs) = if p x then x : filterPred p xs else filterPred p xs

-- Написать вторую реализацию функции fltOdd с использованием filterPred
-- (левую часть определения менять нельзя)

fltOdd' :: Integral a => [a] -> [a]
fltOdd' = filterPred odd
