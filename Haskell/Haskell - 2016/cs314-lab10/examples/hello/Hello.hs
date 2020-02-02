{-# LANGUAGE TemplateHaskell #-}

module Hello where

import Language.Haskell.TH

hello :: ExpQ
hello = [| putStrLn "Hello world" |]
