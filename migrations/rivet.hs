{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -F -pgmF rivet-autoimporter #-}
module Main where

import           Database.Rivet.Adaptor.PostgreSQL
import qualified Database.Rivet.Main               as Rivet
import           System.Environment


main :: IO ()
main = do args <- getArgs
          let mode =
               case args of
                 ["up"] -> Rivet.MigrateUp
                 ["down"] -> Rivet.MigrateDown
                 ["status"] -> Rivet.MigrateStatus
                 _ -> error "Usage: [executable] [devel|prod|...] [up|down|status]"
          adaptor <- setup id (ConnectInfo "localhost" 5432 "monadic_party_user" "111" "monadic_party_db")
          Rivet.main adaptor mode migrations