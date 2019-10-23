module Main where

import Musarithmetic

per1 = Interval "P" 0 
aug1 = Interval "a" 0 
min2 = Interval "m" 1 
maj2 = Interval "M" 1 
min3 = Interval "m" 2 
maj3 = Interval "M" 2 
per4 = Interval "P" 3 
dim5 = Interval "d" 4 
per5 = Interval "P" 4 
min6 = Interval "m" 5 
maj6 = Interval "M" 5 
min7 = Interval "m" 6 
maj7 = Interval "M" 6 

c4      = Pitch 0 4 0
cis4    = Pitch 0 4 1
d4      = Pitch 1 4 0
es4     = Pitch 2 4 (-1)
e4      = Pitch 2 4 0
f4      = Pitch 3 4 0
fis4    = Pitch 3 4 1
fisis4  = Pitch 3 4 2
gb4     = Pitch 4 4 (-1)
g4      = Pitch 4 4 0

main = do
    putStrLn ("c4 + min3 = " ++ show(pitchInc c4 min3))
    putStrLn ("c4 + maj3 = " ++ show(pitchInc c4 maj3))
    putStrLn ("c4 + per5 = " ++ show(pitchInc c4 per5))
    putStrLn ("es4 + min3 = " ++ show(pitchInc es4 min3))
    putStrLn ("es4 + maj3 = " ++ show(pitchInc es4 maj3))
    putStrLn ("es4 + per5 = " ++ show(pitchInc es4 per5))
    putStrLn ("fis4 + min3 = " ++ show(pitchInc fis4 min3))
    putStrLn ("fis4 + maj3 = " ++ show(pitchInc fis4 maj3))
    putStrLn ("fis4 + per5 = " ++ show(pitchInc fis4 per5))
