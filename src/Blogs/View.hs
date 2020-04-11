{-# LANGUAGE OverloadedStrings #-}
module Blogs.View where

import Lucid

import Blogs.Model
import GHC.Natural
import Numeric.Natural
import           Data.Text                          (Text)
import qualified Data.Text                          as T
import Data.Monoid

-- paginatedView :: [Blog] -> Html ()
-- paginatedView blogs = do
--   h1_ "Blogs"
--   mconcat (map blogView blogs)

-- paginatedView :: paginatedItems -> Html () -- hoping that paginatedItems is a list of 5 blogs
-- paginatedView blogs = do
--   h1_ "5 Blogs"
  -- tried using blogView here

blogView :: Blog -> Html ()
blogView (Blog id title description body) = do
  h2_ $ a_ [href_ ("http://localhost:8000//blogs?id=" <> (T.pack (show id)))](toHtml title)
  p_ (toHtml description)

blogsView :: [Blog] -> Natural -> Html () --[Blog] comes from paginatedItems in paginatedViewHandler. Natural is totalPages
blogsView blogs pageTotal = do
  p_ $ toHtml (show pageTotal)
  h1_ "Blogs"
  mconcat (reverse (map blogView blogs))
  a_ [href_ ("http://localhost:8000//blogs?page=1")] "1 "
  a_ [href_ ("http://localhost:8000//blogs?page=2")] "2 "
  a_ [href_ ("http://localhost:8000//blogs?page=3")] "3 "
  a_ [href_ ("http://localhost:8000//blogs?page=4")] "4 "
  a_ [href_ ("http://localhost:8000//blogs?page=5")] "5 "
  br_ mempty
  a_ [href_ ("http://localhost:8000//blogs/create")] "start writing"

blogsForm :: Html ()
blogsForm = do
  h1_ "Add a blog post"
  form_ [method_ "POST", action_ "/blogs/create"] $ do
    label_ $ do
      "Title"
      input_ [name_ "title"]
    label_ $ do
      "Description"
      textarea_ [name_ "description"] ""
    label_ $ do
      "Body"
      textarea_ [name_ "body"] ""
    input_ [type_ "submit"]