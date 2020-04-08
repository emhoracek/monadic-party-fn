module Blogs.View where

import Lucid

import Blogs.Model

-- paginatedView :: [Blog] -> Html ()
-- paginatedView blogs = do
--   h1_ "Blogs"
--   mconcat (map blogView blogs)

-- paginatedView :: paginatedItems -> Html () -- hoping that paginatedItems is a list of 5 blogs
-- paginatedView blogs = do
--   h1_ "5 Blogs"
  -- tried using blogView here

blogView :: Blog -> Html ()
blogView (Blog title body _) = do
  h2_ (toHtml title)
  p_ (toHtml body)

blogsView :: [Blog] -> Html ()
blogsView blogs = do
  h1_ "Blogs"
  mconcat (reverse (map blogView blogs))

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