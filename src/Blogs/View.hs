module Blogs.View where

import Lucid

import Blogs.Model

blogView :: Blog -> Html ()
blogView (Blog title body) = do
  h2_ (toHtml title)
  p_ (toHtml body)

blogsView :: [Blog] -> Html ()
blogsView blogs = do
  h1_ "Blogs"
  mconcat (map blogView blogs)