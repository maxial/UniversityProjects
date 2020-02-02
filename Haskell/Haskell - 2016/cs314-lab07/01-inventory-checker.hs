import Control.Monad
import Data.List
import System.Environment

{-
   Дан текстовый файл (inventory.txt) с перечислением всей имеющейся на складе
   лёгкой брони. Сформируйте список имеющихся полных комплектов брони одного
   вида (kind). 

   Указание: всюду следует использовать монадический синтаксис (операции >>= и >>,
   функции ap, liftM и другие функции монадической обработки данных, использование
   блока do и аппликативного стиля не допускается).
-}

data ArmorType = Shield | Helmet | Gauntlets | Boots | Cuirass
   deriving (Show, Read, Eq, Ord, Enum, Bounded)
data ArmorKind = Chitin | Hide | Leather | Elven | Scaled | Glass | ImperialLight
   deriving (Show, Read, Eq, Ord, Enum, Bounded)
            
data ArmorItem = ArmorItem ArmorKind ArmorType 
   deriving (Show, Eq)
data ArmorKit = ArmorKit ArmorKind [ArmorType]
   deriving (Show, Eq)

loadInventory :: FilePath -> IO [ArmorItem]
loadInventory = undefined

buildArmorKit :: ArmorKind -> [ArmorItem] -> Maybe ArmorKit
buildArmorKit = undefined

buildKits :: [ArmorItem] -> [ArmorKit]
buildKits = undefined

main = (head `liftM` getArgs) >>= loadInventory >>= undefined >>= print
