{-# LANGUAGE CPP, MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric, DeriveAnyClass #-}
module Nominal.Atoms.Signature where

import Control.DeepSeq (NFData)
import GHC.Generics (Generic)
import qualified Nominal.Text.Symbols as Symbols

#if TOTAL_ORDER
import Data.Ratio (denominator, numerator)
import Data.String.Utils (replace)
#endif

----------------------------------------------------------------------------------------------------
-- Relation
----------------------------------------------------------------------------------------------------
data Relation = LessThan | LessEquals | Equals | NotEquals | GreaterEquals | GreaterThan deriving (Eq, Ord, Enum, Generic, NFData)

instance Show Relation where
    show LessThan      = Symbols.lt
    show LessEquals    = Symbols.leq
    show Equals        = Symbols.eq
    show NotEquals     = Symbols.neq
    show GreaterThan   = Symbols.gt
    show GreaterEquals = Symbols.geq

relationAscii :: Relation -> String
relationAscii LessThan = "<"
relationAscii LessEquals = "<="
relationAscii Equals = "="
relationAscii NotEquals = "/="
relationAscii GreaterThan = ">"
relationAscii GreaterEquals = ">="

relations :: [Relation]
relations = [LessThan ..]

symmetricRelation :: Relation -> Relation
symmetricRelation LessThan = GreaterThan
symmetricRelation LessEquals = GreaterEquals
symmetricRelation GreaterThan = LessThan
symmetricRelation GreaterEquals = LessEquals
symmetricRelation Equals = Equals
symmetricRelation NotEquals = NotEquals

relationFunction :: Relation -> (Constant -> Constant -> Bool)
relationFunction LessThan = (<)
relationFunction LessEquals = (<=)
relationFunction GreaterThan = (>)
relationFunction GreaterEquals = (>=)
relationFunction Equals = (==)
relationFunction NotEquals = (/=)

----------------------------------------------------------------------------------------------------
-- Atoms signature
----------------------------------------------------------------------------------------------------

class AtomsSignature where

    -- | Minimum list of relations from signature of atoms type
    minRelations :: [Relation]

    -- | Returns text representation of given constant
    showConstant :: Constant -> String

    -- | Returns constant for text representation
    readConstant :: String -> Constant

    -- | Default constant value
    defaultConstant :: Constant

----------------------------------------------------------------------------------------------------
-- Current atoms type
----------------------------------------------------------------------------------------------------

#if TOTAL_ORDER

type Constant = Rational
instance AtomsSignature where
    minRelations = [Equals, LessThan]
    showConstant x = let (n,d) = (numerator x, denominator x)
                                          in if d == 1 then show n else show n ++ "/" ++ show d
    readConstant x = if elem '/' x then read $ replace "/" "%" x else read $ x ++ "%1"
    defaultConstant = 0

#else

type Constant = Integer
instance AtomsSignature where
    minRelations = [Equals]
    showConstant = show
    readConstant = read
    defaultConstant = 0

#endif
