module M20200331_add_created_at where

  import           Data.Text         (Text)
  import qualified Data.Text         as T
  import           Database.Rivet.V0

  migrate :: Migration IO ()
  migrate = sql up down

  up :: Text
  up = "ALTER TABLE blogs \
       \ ADD COLUMN created_at timestamptz default now()"

  down :: Text
  down = "ALTER TABLE blogs DROP COLUMN created_at"