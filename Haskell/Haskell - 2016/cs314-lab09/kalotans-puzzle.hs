import Control.Monad
import Control.Monad.State
import Data.Maybe

type Var = String
type Value = String
data Predicate = 
             Is Var Value
           | Equal Var Var
           | And Predicate Predicate
           | Or Predicate Predicate
           | Not Predicate
  deriving (Eq, Show)
 
type Variables = [(Var, Value)]

isNot :: Var -> Value -> Predicate
isNot var value = Not (Is var value)
 
implies :: Predicate -> Predicate -> Predicate
implies a b = Not a `Or` b
 
orElse :: Predicate -> Predicate -> Predicate
orElse a b = (a `And` (Not b)) `Or` ((Not a) `And` b)

check :: Variables -> Predicate -> Maybe Bool
check vars (Is var value) = liftM (==value) (lookup var vars)
check vars (Equal v1 v2) = liftM2 (==) (lookup v1 vars) (lookup v2 vars)
check vars (And p1 p2) = liftM2 (&&) (check vars p1) (check vars p2)
check vars (Or  p1 p2) = liftM2 (||) (check vars p1) (check vars p2)
check vars (Not p) = liftM not (check vars p)


data ProblemState = PS {vars::Variables, constraints::[Predicate]}

findVar :: Var -> ProblemState -> Maybe Value
findVar v (PS vs _) = lookup v vs

updateVar :: Var -> Value -> ProblemState -> ProblemState
updateVar v x (PS vs cs) = PS ((v, x) : filter ((v/=).fst) vs) cs

type NDS a = StateT ProblemState [] a

getVar :: Var -> NDS (Maybe Value)
getVar v = findVar v <$> get
 
setVar :: Var -> Value -> NDS ()
setVar v x = modify $ updateVar v x



isConsistent :: Bool -> NDS Bool
isConsistent partial = do 
  cs <- gets constraints
  vs <- gets vars
  return $ all (maybe partial id . check vs) cs
 
getFinalVars :: NDS Variables
getFinalVars = do 
  c <- isConsistent False
  guard c
  gets vars

getSolution :: ProblemState -> NDS a -> Maybe a
getSolution i c = listToMaybe (evalStateT c i)
 
getAllSolutions :: ProblemState -> NDS a -> [a]
getAllSolutions i c = evalStateT c i

said :: Var -> Predicate -> Predicate
said v p = (v `Is` "male") `implies` p
 
saidBoth :: Var -> Predicate -> Predicate -> Predicate
saidBoth v p1 p2 = And ((v `Is` "male") `implies` (p1 `And` p2))
                       ((v `Is` "female") `implies` (p1 `orElse` p2))
 
lied :: Var -> Predicate -> Predicate
lied v p = ((v `said` p) `And` (Not p)) 
                      `orElse` ((v `said` (Not p)) `And` p)

tryAllValues :: Var -> [Value] -> NDS ()
tryAllValues var values = do
  msum $ map (setVar var) values
  c <- isConsistent True
  guard c
  
main :: IO ()
main = do 
  let variables = []
      values = ["male", "female"]
      constraints = [ Not (Equal "parent1" "parent2"),
                        "parent1" `said` ("child" `said` ("child" `Is` "male")),
                         saidBoth "parent2" ("child" `Is` "female")
                                            ("child" `lied` ("child" `Is` "male")) ]
      problem = PS variables constraints
      
  print $ getAllSolutions problem $ do 
     tryAllValues "parent1" values
     tryAllValues "parent2" values
     tryAllValues "child" values
     getFinalVars
