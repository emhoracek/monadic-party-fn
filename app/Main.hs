module Main where

import           Network.Wai.Handler.Warp

import           Site

main :: IO ()
main = do
  putStrLn "Starting server on port 8000"
  app' <- mkApp
  run 8000 app'
