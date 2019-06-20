module Site where

import           Data.Pool                  (createPool)
import qualified Database.PostgreSQL.Simple as PG
import           Network.Wai                (Application, Response)
import           Web.Fn

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
             , path "static" // anything ==> staticServe "static" ]
    `fallthrough` notFoundText "Page not found."

indexHandler :: Ctxt -> IO (Maybe Response)
indexHandler ctxt = okText "hello world"