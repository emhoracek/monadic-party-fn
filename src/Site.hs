module Site where

import           Data.Pool                  (createPool)
import qualified Database.PostgreSQL.Simple as PG
import           Network.Wai                (Application, Response)
import           Web.Fn
import           Data.Text                  (Text)
import           Lucid

import           Context
import           Blogs.Controller

initializer :: IO Ctxt
initializer = do
  let connectInfo = PG.ConnectInfo "localhost" 5432 "monadic_party_user" "111" "monadic_party_db"
  dbPool <- createPool (PG.connect connectInfo) PG.close 1 60 20
  return (Ctxt defaultFnRequest dbPool)

mkApp :: IO Application
mkApp = do
  ctxt <- initializer
  return (toWAI ctxt site)

site :: Ctxt -> IO Response
site ctxt =
  route ctxt [ end ==> indexHandler
             , path "blogs" ==> blogsRoutes
             , path "hello" // segment ==> helloNameH
             , path "hello" // param "name" ==> helloNameH
             , path "hello" // segment ==> rudeHelloH
             , path "add" // segment // segment ==> addNumbersH
             , path "add" // segment // segment ==> addWordsH
             , path "static" // anything ==> staticServe "static" ]
    `fallthrough` notFoundText "Page not found."

helloNameH :: Ctxt -> Text ->  IO (Maybe Response)
helloNameH ctxt name =
  if name == "Libby"
  then return Nothing
  else okText ("Hello, " <> name <> "!")

rudeHelloH :: Ctxt -> Text -> IO (Maybe Response)
rudeHelloH ctxt name = okText "ugh, you again"

addNumbersH :: Ctxt -> Int -> Int -> IO (Maybe Response)
addNumbersH ctxt number1 number2 =
  let sum = number1 + number2 in
  okText (tshow number1 <> " plus " <>
          tshow number2 <> " is " <> tshow sum <> ".")

addWordsH :: Ctxt -> Text -> Text -> IO (Maybe Response)
addWordsH ctxt word1 word2 =
  okText (word1 <> " plus " <> word2 <> " is " <> word1 <> word2 <> ".")

indexHandler :: Ctxt -> IO (Maybe Response)
indexHandler ctxt = okLucid myHtml


myHtml :: Html ()
myHtml = do
  html_ $ do
    head_ $ do
      title_ "Hello monadic party!!"
      style_ "body { background: rebeccapurple }\
             \h1 { color: pink } "
    body_ $ do
      h1_ "Hello <script>alert(\"oh no\")</script> monadic party!!!"
      p_ $ do
        "Testing "
        strong_ " bold "
        "Text "
      img_ [src_ "https://media.giphy.com/media/3rgXBvnbXtxwaWmhr2/giphy.gif"]