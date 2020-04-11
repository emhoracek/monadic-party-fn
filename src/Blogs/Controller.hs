module Blogs.Controller where

import           Data.Maybe         (catMaybes)
import           Data.Text          (Text)
import qualified Data.Text          as T
import           Network.HTTP.Types (StdMethod (..))
import           Network.Wai        (Response)
import           Web.Fn

import           Context
import           Blogs.Model
import           Blogs.View
import           Numeric.Natural
import           GHC.Natural
import           Data.Pagination

blogsRoutes :: Ctxt -> IO (Maybe Response)
blogsRoutes ctxt =
  route ctxt [(param "id" ==> blogViewHandler)
             , (param "page" ==> paginatedViewHandler)
             , (end ==> blogsHandler)
             , (method GET // path "create" ==> blogsFormHandler)
             , (method POST // path "create"
                            // param "title"
                            // param "description"
                            // param "body" !=> blogsCreateHandler)]

blogsHandler :: Ctxt -> IO (Maybe Response)
blogsHandler ctxt = do
  paginatedViewHandler ctxt (PageIndex 1)
  -- blogs <- getBlogs ctxt
  -- okLucid $ blogsView blogs

blogsFormHandler :: Ctxt -> IO (Maybe Response)
blogsFormHandler ctxt = okLucid blogsForm

blogsCreateHandler :: Ctxt -> Text -> Text -> Text -> IO (Maybe Response) -- Texts refer to the three params in the route
blogsCreateHandler ctxt title description body = do
  if title == "" && body == "" then errHtml "invalid input" else do
    success <- createBlog ctxt (NewBlog title description body) --returns a Bool
    if success
        then okHtml "created!"
        -- then okLucid $ blogView _  --how do I get the current blog being created?
        else errHtml "couldn't create blog"

blogViewHandler :: Ctxt -> Int-> IO (Maybe Response)
blogViewHandler ctxt idNum = do
  maybeBlog <- getBlog ctxt idNum
  case maybeBlog of
    Nothing -> return Nothing
    Just blog -> okLucid $ blogView blog 

paginatedViewHandler :: Ctxt -> PageIndex -> IO (Maybe Response)
paginatedViewHandler ctxt pgIndex = do -- pgIndex corresponds to the param in the route
  page <- paginatedBlog ctxt pgIndex -- the return of paginatedBlog is a page of blog posts
  let totalPages = paginatedPagesTotal page
  okLucid $ blogsView (paginatedItems page) totalPages -- paginatedItems takes `a` (page) and returns [a] ([Blog])

 -- paginatedPagesTotal :: Paginated a -> Natural
