{-# LANGUAGE TemplateHaskell #-}

module Main where

import Hello


main = $(hello)
