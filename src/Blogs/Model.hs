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

data NewBlog = NewBlog { newTitle :: Text
                       , newBody  :: Text } deriving (Eq, Show)

instance ToRow NewBlog where
  toRow (NewBlog title body) =
    [ toField title, toField body ]

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
     "INSERT INTO blogs (title, body) VALUES (?, ?)"
     blog)
