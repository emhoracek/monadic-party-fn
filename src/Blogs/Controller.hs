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
  route ctxt [ (end ==> blogsHandler)
             , (method GET // path "create" ==> blogsFormHandler) 
             , (method POST // path "create"
                            // param "title"
                            // param "body" !=> blogsCreateHandler)]

blogsHandler :: Ctxt -> IO (Maybe Response)
blogsHandler ctxt = do
  blogs <- getBlogs ctxt
  okLucid $ blogsView blogs

blogsFormHandler :: Ctxt -> IO (Maybe Response)
blogsFormHandler ctxt = okLucid blogsForm

blogsCreateHandler :: Ctxt -> Text -> Text -> IO (Maybe Response)
blogsCreateHandler ctxt title body = do
  if title == "" && body == "" then errHtml "invalid input" else do
    success <- createBlog ctxt (NewBlog title body)
    if success
        then okHtml "created!"
        else errHtml "couldn't create blog"