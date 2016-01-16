module Nominal.Variants (
Variants,
variant,
fromVariant,
iteV,
toList,
fromList,
satisfying,
Nominal.Variants.map,
variantsRelation) where

import Data.List.Utils (join)
import Data.Map (Map)
import qualified Data.Map as Map
import Nominal.Conditional
import Nominal.Contextual
import Nominal.Formula
import Prelude hiding (or, not)

----------------------------------------------------------------------------------------------------
-- Variants
----------------------------------------------------------------------------------------------------

-- | Storing values under various conditions, which could not be solved as 'true' or 'false'.
-- Is often the result of 'ite' or 'iteV' functions.
data Variants a = Variants (Map a Formula) deriving (Eq, Ord)

-- | Creates a single variant.
variant :: a -> Variants a
variant x = Variants $ Map.singleton x true

instance Show a => Show (Variants a) where
    show (Variants vs) = join " | " (fmap showVariant $ Map.assocs vs)
      where showVariant (v, c) = show v ++ if c == true then "" else " : " ++ show c

instance Ord a => Conditional (Variants a) where
    cond c (Variants vs1) (Variants vs2) = Variants $ unionVariants c vs1 vs2
      where filterWith c = Map.filter (/= false) . Map.map (/\ c)
            unionVariants c vs1 vs2 = Map.unionWith (\/) (filterWith c vs1) (filterWith (not c) vs2)

instance (Contextual a, Ord a) => Contextual (Variants a) where
    when ctx = fromList . fmap (\(v,c) -> (when (ctx /\ c) v, when ctx c)) . toList

-- | /If ... then ... else/ ... for types that are not instances of 'Conditional' class.
iteV :: Ord a => Formula -> a -> a -> Variants a
iteV c x1 x2 = ite c (variant x1) (variant x2)

toList :: Variants a -> [(a, Formula)]
toList (Variants vs) = Map.assocs vs

fromList :: Ord a => [(a, Formula)] -> Variants a
fromList = Variants . Map.filter (/= false) . Map.fromListWith (\/)

values :: Variants a -> [a]
values (Variants vs) = Map.keys vs

satisfying :: (a -> Bool) -> Variants a -> Formula
satisfying f (Variants vs) = or $ Map.elems $ Map.filterWithKey (const . f) vs

map :: Ord b => (a -> b) -> Variants a -> Variants b
map f (Variants vs) = Variants (Map.mapKeysWith (\/) f vs)

-- | Returns value of a single variant.
fromVariant :: Variants a -> a
fromVariant vs = case values vs of
                v:[] -> v
                otherwise -> error "Nominal.Variants.fromVariant: not single variant"

variantsRelation :: (a -> a -> Formula) -> Variants a -> Variants a -> Formula
variantsRelation r vs1 vs2 = or [(r v1 v2) /\ c1 /\ c2 | (v1, c1) <- toList vs1, (v2, c2) <- toList vs2]
