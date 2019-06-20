module FirstSite where

import Web.Fn
import Network.Wai (Application, Response)
import Network.Wai.Handler.Warp (run)

data Ctxt = Ctxt FnRequest

instance RequestContext Ctxt where
  getRequest (Ctxt req) = req
  setRequest (Ctxt oldReq) newReq = Ctxt newReq

site :: Ctxt -> IO Response
site ctxt =
  route ctxt [ end ==> indexH ]
        `fallthrough` notFoundText "Page not found."

indexH :: Ctxt -> IO (Maybe Response)
indexH ctxt = okText "Welcome to my first Haskell website."

start :: IO ()
start = run 8000 waiApp

initCtxt :: Ctxt
initCtxt = Ctxt defaultFnRequest

waiApp :: Application
waiApp = toWAI initCtxt site