{- Реализуйте функцию TemplateHaskell, которая по заданному имени типа
   возвращает количество его конструкторов данных. -}

{-# LANGUAGE TemplateHaskell #-}

data Point = Point Double Double

data Complex = Polar Double Double | Rectangular Double Double

data Shape = Circle Double | Square Double | Triangle Double Double Double

-- Должно быть True
test = $(countConstrs ''Point) == 1 && $(countConstrs ''Complex) == 2 && $(countConstrs ''Shape) == 3
