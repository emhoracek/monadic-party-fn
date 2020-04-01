module Blogs.Model where

import           Data.Maybe                         (listToMaybe)
import           Data.Pool                          (withResource)
import           Data.Text                          (Text)
import qualified Database.PostgreSQL.Simple         as PG
import           Database.PostgreSQL.Simple.FromRow
import           Database.PostgreSQL.Simple.ToField
import           Database.PostgreSQL.Simple.ToRow
import           Data.Time.Clock (UTCTime)
import           Context

data Blog = Blog { title :: Text
                 , body  :: Text
                 , createdAt :: UTCTime } deriving (Eq, Show)

instance FromRow Blog where
  fromRow = Blog <$> field <*> field <*> field

data NewBlog = NewBlog { newTitle :: Text  -- second blog type that is put into the db, not read from it (no created_at field in form)
                       , newDescription :: Text
                       , newBody  :: Text } deriving (Eq, Show)

instance ToRow NewBlog where
  toRow (NewBlog title description body) =
    [toField title, toField description, toField body]

getBlog :: Ctxt -> Int -> IO (Maybe Blog) -- called by blogViewHandler in Controller
getBlog ctxt idNum =
  listToMaybe <$> withResource (db ctxt) (\conn ->
    PG.query --no underscore if passing in a param
     conn
     "SELECT title, body, created_at FROM blogs WHERE id = ?"
     (PG.Only idNum))

getBlog2 ctxt idNum = do
  res <- withResource (db ctxt) (\conn ->
          PG.query_ -- doesn't take params
          conn
          "SELECT title, body, created_at FROM blogs WHERE id = idNum")
  case res of
    [] -> return Nothing
    (x : xs) -> return (Just x) 
     


{-
myWithResource :: Connection -> (Connection -> a) -> a
myWithResource conn yourFunc = 
  openConnection conn
  res <- yourFunc conn
  closeConnection conn
  return res
-}

getBlogs :: Ctxt -> IO [Blog]
getBlogs ctxt =
  withResource (db ctxt) (\conn ->
    PG.query_
     conn
     "SELECT title, body, created_at FROM blogs")

createBlog :: Ctxt -> NewBlog -> IO Bool
createBlog ctxt blog = (==) 1 <$>
  withResource (db ctxt) (\conn ->
    PG.execute
     conn
     "INSERT INTO blogs (title, description, body) VALUES (?, ?, ?)"
     blog)
