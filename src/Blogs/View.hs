module Blogs.View where

import Lucid

import Blogs.Model

blogView :: Blog -> Html ()
blogView (Blog title body _) = do
  h2_ (toHtml title)
  p_ (toHtml body)

blogsView :: [Blog] -> Html ()
blogsView blogs = do
  h1_ "Blogs"
  mconcat (map blogView blogs)

blogsForm :: Html ()
blogsForm = do
  h1_ "Add a blog post"
  form_ [method_ "POST", action_ "/blogs/create"] $ do
    label_ $ do
      "Title"
      input_ [name_ "title"]
    label_ $ do
      "Body"
      textarea_ [name_ "body"] ""
    input_ [type_ "submit"]