{-# LANGUAGE TemplateHaskell #-}

module Main where

import Pr

$(mkProjections [2..10])

main = do
  putStrLn $ proj_3_1 (undefined,"Success!",undefined)
  putStrLn $ proj_4_2 (undefined,undefined,"Success!",undefined)
  putStrLn $ proj_5_4 (undefined,undefined,undefined,undefined,"Success!")
--  putStrLn $ $(pr 3 10) (undefined,undefined,undefined,undefined,"Success!")
