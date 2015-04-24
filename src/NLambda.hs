module NLambda where

import Nominal.Conditional
import Nominal.Either
import Nominal.Formula
import Nominal.Formula.Solver
import Nominal.Graph
import Nominal.Maybe
import Nominal.Set
import Nominal.Type
import Nominal.Variable
import Nominal.VariablesSpace
import Nominal.Variants hiding (filter, fromList, map)
import Prelude hiding (or, and, not, sum, map, filter, maybe)

----------------------------------------------------------------------------------------------------
-- Examples
----------------------------------------------------------------------------------------------------
x = variable "x"
y = variable "y"
z = variable "z"
cc = eq x y
ncc = not cc
ce = (eq x y) /\ (eq y z) /\ (eq z x)
nce =  (eq x y) /\ (eq y z) /\ not (eq z x)
ice = (eq x y) /\ (eq y z) ==> (eq z x)
af = (∀) y cc
ef = (∃) y cc
aef = (∀) x $ (∃) y cc
naef = not aef
eaf = (∃) x $ (∀) y cc
aaf = (∀) x $ (∀) y cc
eef = (∃) x $ (∃) y cc

a = atom "a"
b = atom "b"
c = atom "c"
cond = eq a b
at = iF cond a b
set1 = singleton at
set2 = fromList [a, b]
set3 = fromList [a, b, c]
sa = atoms
da = delete a sa
ts = triples sa sa sa

a1 = variant $ iterationVariable 0 1
b1 = variant $ iterationVariable 1 1

-- example program

nlProgram = do
    a <- newAtom
    b <- newAtom
    return $ let set = insert a atoms
             in insert b set


g = atomsGraph $ filter (\(x,y) -> eq x a \/ eq y a) atomsPairs
gIn = atomsGraph $ filter (eq a . snd) atomsPairs
gOut = atomsGraph $ filter (eq a . fst) atomsPairs
gAB = addEdge (a,b) emptyGraph
bigraph = atomsGraph $ filter (\(x,y) -> (lt x a /\ lt y a) \/ (gt x a /\ gt y a)) atomsPairs
bigraphMonotonic = atomsGraph $ filter (\(x,y) -> (lt x y) /\ ((lt x a /\ lt y a) \/ (gt x a /\ gt y a))) atomsPairs