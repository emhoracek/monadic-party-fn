module Typeclasses where

data Class = Bard | Fighter | Druid | Paladin
  deriving Show

data Character =
  Character { charaName :: String
            , charaClass :: Class }

instance Show Character where
  show (Character cName cClass) = cName ++ " is the " ++ show cClass

character = Character "Hela" Fighter