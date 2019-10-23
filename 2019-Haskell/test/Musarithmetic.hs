-- musarithmetic
-- Andrew A. Cashner
-- 2019/10/22
-- First program in Haskell
-- Do arithmetic with pitches: e.g., g4 + P5 = d5, eb3 - M3 = c3, g4 - c4 = P5

module Musarithmetic (
    Interval(..), 
    Pitch(..), 
    pitchInc
) where

-- PITCH
-- Pitch contains 0-indexed number of a diatonic pitch class (c = 0)
-- Octave is Helmholtz octave number
-- Accid is integer in range [(-2)..2]
data Pitch = Pitch {
    pnum :: Int,
    oct :: Int,
    accid :: Int 
} 

instance Show Pitch where
    show (Pitch pnum oct accid) = pname : accidName ++ show oct 
        where
            pname = "cdefgab" !! pnum
            accidName = ["bb", "b", "", "#", "x"] !! (accid + 2)

-- CONVERSION
-- convert between Pitch and absolute pitch number in a given base
-- diatonic (base 7) and chromatic(base 12)

-- Pitch to pitch class (int)
--  diatonic
--      ignore accidental
pitch2pcDia :: Pitch -> Int
pitch2pcDia (Pitch pnum oct accid) = 7 * oct + pnum

--  chromatic
--      need to convert diatonic pnum to chromatic first
--      and add chromatic accidental
pitch2pcChrom :: Pitch -> Int
pitch2pcChrom (Pitch pnum oct accid) = 12 * oct + (pnumDia2Chrom pnum) + accid

-- get chromatic pitch-class number (e.g., D = 2)
pnumDia2Chrom :: Int -> Int
pnumDia2Chrom n = [0, 2, 4, 5, 7, 9, 11] !! n


-- Pitch class (int) to Pitch
--  diatonic
--      Convert to base 7:
--          "7s" digit (quotient) = octave, "1s" digit (remainder) = pnum
--      Need to pass accidental explicitly because this information is not
--          stored in diatonic pitch-class number 
pc2pitch :: Int -> Int -> Pitch
pc2pitch pnum accid = 
    Pitch {
        oct = (fst converted),
        pnum = (snd converted),
        accid = accid
    } where
        converted = quotRem pnum 7

-- INTERVAL
-- quality is e.g.,"P" or "m"
-- degree is the diatonic steps (P5 = "P" 4)
-- 0-indexed
data Interval = Interval {
    quality :: String,
    degree :: Int
} 

instance Show Interval where
   show (Interval quality degree) = quality ++ show degree

-- Is the interval in the list of perfect intervals?
intervalPerfect :: Interval -> Bool
intervalPerfect (Interval quality degree) = elem degree [0, 3, 4]

-- Convert the interval to chromatic steps
intervalChrom :: Interval -> Int
intervalChrom i = steps + adjust
    where
        steps = pnumDia2Chrom (degree i)
        adjust = case (lookup (quality i) adjustMap) of
            Just x -> x
            Nothing -> error "Unknown interval quality"

        adjustMap
            | intervalPerfect i = perfectAdjustment 
            | otherwise = imperfectAdjustment 
        
        imperfectAdjustment = 
            [("dd", 0 - 3), 
             ("d",  0 - 2),
             ("m",  0 - 1),
             ("M",  0),
             ("a",  1),
             ("aa", 2)] 

        perfectAdjustment = 
            [("dd", 0 - 2), 
             ("d",  0 - 1), 
             ("P",  0),
             ("a",  1),
             ("aa", 2)] 

-- difference of two absolute chromatic pitch numbers
pitchDiffChrom :: Pitch -> Pitch -> Int
pitchDiffChrom p1 p2 = pitch2pcChrom p1 - pitch2pcChrom p2

-- PITCH ARITHMETIC

-- increase pitch by diatonic steps
pitchIncDia :: Pitch -> Int -> Pitch
pitchIncDia p n = pc2pitch (pitch2pcDia p + n) (accid p)

-- increase pitch by Interval
    -- accid is the difference between the diatonic sum with
    --   accidental and the absolute chromatic sum 
pitchInc :: Pitch -> Interval -> Pitch
pitchInc p i = 
    Pitch { 
        pnum = pnum newPitchDia, 
        oct = oct newPitchDia, 
        accid = (accid p) + (newpcChrom - pitch2pcChrom newPitchDia)
    } where
        newPitchDia = pitchIncDia p (degree i)
        newpcChrom = pitch2pcChrom p + intervalChrom i

pitch8va :: Pitch -> Pitch
pitch8va p = pitchIncDia p 7

pitch8vb :: Pitch -> Pitch
pitch8vb p = pitchIncDia p (-7)


