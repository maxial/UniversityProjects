import Data.List

-- 1) Пользуясь функцией find и инструкцией case, определить, имеются ли в данном
--    целочисленном списке положительные нечётные элементы.

hasPosOdd :: [Integer] -> Bool
hasPosOdd = undefined

-- 2) Дан список. Найти в нём наименьший нечётный элемент.

smallest_odd :: (Eq a, Ord a, Integral a) => [a] -> Maybe a
smallest_odd = foldl step Nothing
  where
    -- step :: ???
    step Nothing x = undefined
    step (Just m) x = undefined

-- 3) Пользуясь функциями sortBy и comparing, упорядочить заданный список точек на плоскости по
--    убыванию ординат

data Point = Point {x :: Double, y :: Double}
  deriving (Show, Eq, Ord)

sortByY :: [Point] -> [Point]
sortByY = undefined

-- 4) Дополнить тип для геометрических фигур треугольником и дополнить реализацию
--    функций вычисления площади и периметра.

type Radius = Double

data Shape = Circle Point Radius | Rectangle Point Point
                deriving (Show)

area :: Shape -> Double
area (Circle _ r) = pi * r ^ 2
area (Rectangle (Point x1 y1) (Point x2 y2)) = 
                            (abs $ x2 - x1) * (abs $ y2 - y1)

perimeter :: Shape -> Double
perimeter = undefined

-- 5) Реализовать аналоги стандартных функций head, tail, length, last, map и filter
--    для объявленного на лекции типа List a.

data List a = Nil | Cons a (List a)

head' :: List a -> a
head' = undefined

tail' :: List a -> List a
tail' = undefined

length' :: List a -> Int
length' = undefined

last' :: List a -> a
last' = undefined

map' :: (a -> b) -> List a -> List b
map' = undefined

filter' :: (a -> Bool) -> List a -> List a
filter' = undefined

-- 6) Пользуясь функцией unfoldr, реализовать построение произвольной числовой последовательности,
--    каждый элемент которой вычисляется через два предыдущих.

iterate2 :: (a -> a -> a) -> a -> a -> [a]
iterate2 next a1 a2 = undefined
