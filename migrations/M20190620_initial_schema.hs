module M20190620_initial_schema where

import           Data.Text         (Text)
import qualified Data.Text         as T
import           Database.Rivet.V0

migrate :: Migration IO ()
migrate = sql up "DROP TABLE blogs CASCADE;"

up :: Text
up = "CREATE TABLE blogs ( \
      \  id serial primary key, \
      \  title text not null, \
      \  body text not null \
      \);"

