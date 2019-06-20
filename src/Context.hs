module Context where

import           Data.Pool
import           Data.Text                  (Text)
import qualified Data.Text                  as T
import qualified Data.Text.Lazy             as LT
import qualified Database.PostgreSQL.Simple as PG
import           Network.Wai                (Response)
import           Lucid
import           Web.Fn

data Ctxt = Ctxt { req :: FnRequest
                 , db  :: Pool PG.Connection }

instance RequestContext Ctxt where
  getRequest ctxt = req ctxt
  setRequest ctxt newReq = ctxt { req = newReq }

tshow :: Int -> Text
tshow = T.pack . show

okLucid :: Html () -> IO (Maybe Response)
okLucid html = okHtml $ LT.toStrict $ renderText html