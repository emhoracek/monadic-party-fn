module M20200401_add_description_to_blogs where

  import           Data.Text         (Text)
  import qualified Data.Text         as T
  import           Database.Rivet.V0

  migrate :: Migration IO ()
  migrate = sql up down

  up :: Text
  up = "ALTER TABLE blogs \
       \ ADD COLUMN description text"

  down :: Text
  down = "ALTER TABLE blogs DROP COLUMN description"