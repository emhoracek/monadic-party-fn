module Blogs.Model where

import           Data.Maybe                         (listToMaybe)
import           Data.Pool                          (withResource)
import           Data.Text                          (Text)
import qualified Database.PostgreSQL.Simple         as PG
import           Database.PostgreSQL.Simple.FromRow
import           Database.PostgreSQL.Simple.ToField
import           Database.PostgreSQL.Simple.ToRow

import           Context

data Blog = Blog { title :: Text
                 , body  :: Text } deriving (Eq, Show)

instance ToRow Blog where
  toRow (Blog title body) =
    [toField title, toField body ]

instance FromRow Blog where
  fromRow = Blog <$> field <*> field

getBlogs :: Ctxt -> IO [Blog]
getBlogs ctxt =
  withResource (db ctxt) (\conn ->
    PG.query_
     conn
     "SELECT title, body FROM blogs"
       :: IO [ Blog ])

createBlog :: Ctxt -> Blog -> IO Bool
createBlog ctxt blog = (==) 1 <$>
  withResource (db ctxt) (\conn ->
    PG.execute
     conn
     "INSERT INTO blogs (title, body) VALUES (?, ?)"
     blog)
