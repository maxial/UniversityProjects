{-
   В этом упражнении вводятся кортежи — гетерогенные наборы данных
   (кортеж содержит несколько элементов разных типов).
   Кортеж из двух элементов называется парой.
-}

-- 1)
-- Написать функцию, которая принимает на вход пару целых чисел и возвращает их
-- сумму и произведение.
-- Для доступа к первому и второму элементу пары можно использовать функции fst и snd.

sumprod :: (Integer, Integer) -> (Integer, Integer)
sumprod p = (fst p + snd p, fst p * snd p)

-- должно быть True
test1 = sumprod (2, 3) == (5, 6) && sumprod (-4, 5) == (1, -20)

-- 2)
-- Написать функцию, которая разбивает промежуток времени в секундах на часы, минуты и секунды.
-- Например, промежуток в 5467 секунд имеет продолжительность в 1 час, 31 минуту и 7 секунд.
-- Результат возвращать в виде кортежа из трёх элементов. Реализовать также обратное преобразование.

sec2hms :: Int -> (Int, Int, Int)
sec2hms s = (s `div` 3600, s `mod` 3600 `div` 60, s `mod` 60)

hms2sec :: (Int, Int, Int) -> Int
-- Здесь используется сопоставление с образцом для кортежей
-- (сопоставляются элементы кортежа)
hms2sec (h, m, s) = h * 3600 + m * 60 + s

-- Реализовать с помощью hms2sec (здесь параметры заданы по отдельности)
hms2sec' :: Int -> Int -> Int -> Int
hms2sec' h m s = hms2sec (h, m, s)

-- должно быть True (тело функции можно не смотреть)
test2 = and $ map (\x -> x == hms2sec (sec2hms x)) [1,10..10000]

-- 3) 
-- Написать функции, вычисляющие
-- а) длину отрезка по координатам его концов;
-- б) периметр и площадь треугольника по координатам вершин.

-- Синоним типа
type Point = (Double, Double)

distance :: Point -> Point -> Double
distance (x1, y1) (x2, y2) = sqrt ((x1 - x2)^2 + (y1 - y2)^2)

triangle :: Point -> Point -> Point -> (Double, Double)
triangle p1 p2 p3 = (p, s)
  where
    a = distance p1 p2
    b = distance p2 p3
    c = distance p3 p1
    p = a + b + c
    s = let pp = p / 2 in sqrt (pp * (pp - a) * (pp - b) * (pp - c))