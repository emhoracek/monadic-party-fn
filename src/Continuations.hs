module Continuations where

examples :: IO ()
examples = do
  printf (c"hello") -- should be "hello"
  printf s "hello" -- should be "hello"
  printf (c"The answer is " % d) 42 -- should be "The answer is 42"
  printf (c"I have " % d % c" " % s) 2 "cats" -- should be "I have 2 cats"

printf :: ((String -> IO ()) -> a) -> a
printf format = format putStrLn

c str k = k str

d :: (Num n, Show n) => (String -> a) -> n -> a
d k i = k (show i)

s = id

(%) f1 f2 k = f1 (f2 . concatK)
  where concatK s1 s2 = k (s1 ++ s2)