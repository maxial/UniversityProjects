{-
 1) Дан список слов.
  a) Преобразовать все слова к верхнему регистру.
  b) Извлечь из него подсписок слов заданной длины.
  c) Извлечь из него подсписок слов, начинающихся с заданной буквы.
  d) Извлечь из него подсписок слов, начинающихся и заканчивающихся
     с одной и той же буквы.
-}

wsToUpper :: [String] -> [String]
wsToUpper = undefined

wsByLength :: Int -> [String] -> [String]
wsByLength = undefined

wsByFirstChar :: Char -> [String] -> [String]
wsByFirstChar = undefined

wsSameChar :: [String] -> [String]
wsSameChar = undefined

{-
  2) Дана строка, содержащая слово и, возможно,
  лидирующие и последующие пробелы или знаки пунктуации.
  Очистить строку от лишних символов.

  В решении могут пригодиться функции dropWhile и takeWhile,
  а также предикаты из списка:
  https://www.haskell.org/hoogle/?hoogle=Char+-%3E+Bool

  Слова с дефисами должны обрабатываться корректно.
-}

cleanWord :: String -> String
cleanWord = undefined

test_cleanWord = (all (=="слово")
                   $ map cleanWord ["слово", "  слово    ", "слово,",
                                    "!слово!", " -слово-"])
                 && cleanWord " чудо-юдо   " == "чудо-юдо"

-- 3) Дана строка, содержащая предложение на русском языке.
--    Посчитать количество содержащихся в ней n-буквенных слов.

wscount :: Int -> String -> Int
wscount n = undefined . filter (undefined n) . undefined cleanWord . words

-- 4) Дан текст в виде строки символов, содержащий среди прочего
--    числовые данные. Посчитать количество всех встречающихся в тексте чисел.

countNumbers :: String -> Int
countNumbers = undefined

test_countNumbers = countNumbers "Brick 123 quiz whangs 234 jumpy 3 veldt 444 fox!" == 4


