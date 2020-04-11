module Blogs.Model where

import           Data.Maybe                         (listToMaybe)
import           Data.Pool                          (withResource)
import           Data.Text                          (Text)
import qualified Data.Text                          as T
import qualified Database.PostgreSQL.Simple         as PG
import           Database.PostgreSQL.Simple.FromRow
import           Database.PostgreSQL.Simple.ToField
import           Database.PostgreSQL.Simple.ToRow
import           Data.Time.Clock (UTCTime)
import           Context
import           Data.Pagination
import           Numeric.Natural
import           GHC.Natural
import           Web.Fn

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

newtype PageIndex = PageIndex { unPageIndex :: Natural } deriving (Eq, Show)

instance FromParam PageIndex where -- fromParam :: [Text] -> Either ParamError a
  fromParam [x] = Right (PageIndex (read (T.unpack x)))
  fromParam [] = Left ParamMissing
  fromParam _ = Left ParamTooMany

getBlog :: Ctxt -> Int -> IO (Maybe Blog) -- called by blogViewHandler in Controller
getBlog ctxt idNum =
  listToMaybe <$> withResource (db ctxt) (\conn ->
    PG.query --no underscore if passing in a param
     conn
     "SELECT title, body, created_at FROM blogs WHERE id = ?"
     (PG.Only idNum))

{- -Another way to do getBlog-
getBlog2 ctxt idNum = do
  res <- withResource (db ctxt) (\conn ->
          PG.query_ -- doesn't take params
          conn
          "SELECT title, body, created_at FROM blogs WHERE id = ?")
  case res of
    [] -> return Nothing
    (x : xs) -> return (Just x) 
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

getBlogCount :: Ctxt -> IO Int
getBlogCount ctxt = do
  bCount <- withResource (db ctxt) (\conn ->
    PG.query_
     conn
     "SELECT COUNT(*) FROM blogs")
  case bCount of
    [PG.Only n] -> return n
    whatever -> error $ "Blog count returned: " ++ show whatever

postsPerPage = 3

paginatedBlog :: Ctxt -> PageIndex -> IO (Paginated Blog)
paginatedBlog ctxt pgIndex = do
  blogCount <- intToNatural <$> length <$> ( getBlogs ctxt ) -- get total number of blogs posts. use fmap to get it out of IO
  case mkPagination postsPerPage (unPageIndex pgIndex) of
    Nothing -> error "Something went wrong :("
    Just blogPost -> paginate blogPost blogCount (blogCallback ctxt) -- partial application/ctxt from callback


blogCallback :: Ctxt -> Int -> Int -> IO [Blog]
blogCallback ctxt offset limit =
  withResource (db ctxt) (\conn ->
    PG.query
     conn
     "SELECT title, body, created_at FROM blogs \
     \ORDER BY title DESC \
     \LIMIT ? OFFSET ?"
     (limit, offset)) -- tuples can be entered into the database/are of the ToRow typeclass
     

{- this is what withResource does!
myWithResource :: Connection -> (Connection -> a) -> a
myWithResource conn yourFunc = 
  openConnection conn
  res <- yourFunc conn
  closeConnection conn
  return res
-}