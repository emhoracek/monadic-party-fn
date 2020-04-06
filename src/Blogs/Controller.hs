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

blogsRoutes :: Ctxt -> IO (Maybe Response)
blogsRoutes ctxt =
  route ctxt [(param "id" ==> blogViewHandler)
             , (end ==> blogsHandler)
             , (method GET // path "create" ==> blogsFormHandler)
             , (method POST // path "create"
                            // param "title"
                            // param "description"
                            // param "body" !=> blogsCreateHandler)] -- why !=> ?

blogsHandler :: Ctxt -> IO (Maybe Response)
blogsHandler ctxt = do
  blogs <- getBlogs ctxt
  okLucid $ blogsView blogs

blogsFormHandler :: Ctxt -> IO (Maybe Response)
blogsFormHandler ctxt = okLucid blogsForm

blogsCreateHandler :: Ctxt -> Text -> Text -> Text -> IO (Maybe Response)
blogsCreateHandler ctxt title description body = do
  if title == "" && body == "" then errHtml "invalid input" else do
    success <- createBlog ctxt (NewBlog title description body)
    if success
        then okHtml "created!"
        else errHtml "couldn't create blog"

blogViewHandler :: Ctxt -> Int-> IO (Maybe Response)
blogViewHandler ctxt idNum = do
  maybeBlog <- getBlog ctxt idNum
  case maybeBlog of
    Nothing -> return Nothing
    Just blog -> okLucid $ blogView blog 


paginatedViewHandler :: Ctxt -> Int -> IO (Maybe Response)
paginatedViewHandler ctxt pgIndex = do -- pgIndex corresponds to the param in the route
  blogCount <- intToNatural <$> length <$> ( getBlogs ctxt ) -- get number of blogs to pass into paginatedBlog below. use fmap to get it out of IO
  let pgIndexNat = intToNatural pgIndex -- we need Naturals for pagination
  page <- paginatedBlog ctxt pgIndexNat blogCount -- the return of paginatedBlog is a page of blog posts
  okLucid $ blogsView (paginatedItems page) -- paginatedItems takes `a` (page) and returns [a] ([Blog])
