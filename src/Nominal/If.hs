{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}

module Nominal.If (ifThenElse) where

import NLambda

class IfThenElse i a where
  ifThenElse :: i -> a -> a -> a

instance Conditional a => IfThenElse Formula a where
  ifThenElse = ite

instance IfThenElse Bool a where
  ifThenElse True a b = a
  ifThenElse False a b = b
