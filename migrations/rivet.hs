{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Database.Rivet.Adaptor.PostgreSQL
import qualified Database.Rivet.Main               as Rivet
import           System.Environment

import qualified M20190620_initial_schema
import qualified M20200331_add_created_at
import qualified M20200401_add_description_to_blogs


main :: IO ()
main = do args <- getArgs
          let mode =
               case args of
                 ["up"] -> Rivet.MigrateUp
                 ["down"] -> Rivet.MigrateDown
                 ["status"] -> Rivet.MigrateStatus
                 _ -> error "Usage: [executable] [devel|prod|...] [up|down|status]"
          adaptor <- setup id (ConnectInfo "localhost" 5432 "monadic_party_user" "111" "monadic_party_db")
          Rivet.main adaptor mode [("M20190620_initial_schema", M20190620_initial_schema.migrate)
                                  , ("M20200331_add_created_at", M20200331_add_created_at.migrate)
                                  , ("M20200401_add_description_to_blogs", M20200401_add_description_to_blogs.migrate)]