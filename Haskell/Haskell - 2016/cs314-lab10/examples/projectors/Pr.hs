{-# LANGUAGE TemplateHaskell #-}

module Pr where

import Language.Haskell.TH

proj :: Int -> Int -> Q Exp
proj n k
  | n > 1 && 0 <= k && k < n = do
     x <- newName "x"
     let mkPat j
          | j == k = varP x
          | otherwise = wildP
     [| \ $(tupP $ map mkPat [0..n-1]) -> $(varE x) |]
  | otherwise = fail "impossible projection"

projections :: Int -> Q [Dec]
projections n = fmap concat . mapM mkDecl $ [0..n-1] where
  mkDecl k = do
    let nm = mkName $ "proj_" ++ show n ++ "_" ++ show k
    [d| $(varP nm) = $(proj n k) |]

mkProjections :: [Int] -> Q [Dec]
mkProjections = fmap concat . mapM projections


{-
proj 3 1 = do
   x <- newName "x"
   let args = [WildP,VarP x,WildP]
   return $ LamE [TupP args] (VarE x)
-}
{-
proj :: Int -> Int -> ExpQ
proj n k
  | n > 1 && 0 <= k && k < n = do
     x <- newName "x"
     let mkPatQ j
          | j == k = varP x
          | otherwise = wildP
     [| \ $(tupP . map mkPatQ $ [0..n-1]) -> $(varE x) |]
  | otherwise = fail "impossible projection"
-}
{-
pr :: Int -> Int -> Q Exp
pr 3 1 = do
--  x <- newName "x"
--  return $ LamE [TupP [WildP,VarP x,WildP]] (VarE x)
  [| \ (x, y, z) -> y |]
-}
