{- Не меняя ничего в этом файле, добейтесь, чтобы
   он компилировался и печатал три строки с текстом Hello
   и 5 строк с текстом "Bye". -}

{-# LANGUAGE TemplateHaskell #-}

import Reporter

main = do
   $(rpt 3) "Hello"
   $(rpt 5) "Bye"
