\documentclass{article}
%include polycode.fmt
\usepackage[margin=1in]{geometry}
\usepackage{parskip}
\usepackage{enumitem}
\setlist{nosep}

\title{@musarithmetic@: Do arithmetic with musical pitches}
\author{Andrew A. Cashner}
\date{2019/10/23}

\begin{document}
\maketitle

\section{History}

First Haskell program, 2019/10/22--23

\section{Purpose}

Do arithmetic with pitches.
For example, @g4 + P5 = d5, eb3 - M3 = c3, g4 - c4 = P5@.

\section{Module Definition}
\begin{code}
module Musarithmetic (
    Interval(..), 
    Pitch(..), 
    pitchInc
) where
\end{code}

\section{Pitch Datatype}

\begin{itemize}
\item Pitch contains 0-indexed number of a diatonic pitch class @(c = 0)@
\item Octave is Helmholtz octave number
\item Accid is integer in range @[(-2)..2]@
\end{itemize}

\begin{code}
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
\end{code}

\section{Conversion}

Convert between Pitch and absolute pitch number in a given base:
diatonic (base 7) and chromatic(base 12).

\subsection{@Pitch@ to pitch class (@int@)}
\subsubsection{Diatonic}
Ignore the accidental, just add diatonic steps to base pitch.

\begin{code}
pitch2pcDia :: Pitch -> Int
pitch2pcDia (Pitch pnum oct accid) = 7 * oct + pnum
\end{code}

\subsubsection{Chromatic}
Need to convert diatonic pnum to chromatic first and add chromatic accidental.

\begin{code}
pitch2pcChrom :: Pitch -> Int
pitch2pcChrom (Pitch pnum oct accid) = 12 * oct + (pnumDia2Chrom pnum) + accid
\end{code}

Get chromatic pitch-class number (e.g., @D = 2@).
\begin{code}
pnumDia2Chrom :: Int -> Int
pnumDia2Chrom n = [0, 2, 4, 5, 7, 9, 11] !! n
\end{code}

\subsection{Pitch class (@int@) to @Pitch@}
\subsubsection{Diatonic}

Convert to base 7: ``7s'' digit (quotient) is octave, ``1s'' digit (remainder)
is pitch number.
Need to pass accidental explicitly because this information is not stored in
diatonic pitch-class number.

\begin{code}
pc2pitch :: Int -> Int -> Pitch
pc2pitch pnum accid = 
    Pitch {
        oct = (fst converted),
        pnum = (snd converted),
        accid = accid
    } where
        converted = quotRem pnum 7
\end{code}

\section{Interval Datatype}
\begin{itemize}
\item Quality is e.g., @"P"@ or @"m"@
\item Degree is the diatonic steps @(P5 = "P" 4)@
\item 0-indexed
\end{itemize}

\begin{code}
data Interval = Interval {
    quality :: String,
    degree :: Int
} 

instance Show Interval where
   show (Interval quality degree) = quality ++ show degree
\end{code}

Is the interval in the list of perfect intervals?
\begin{code}
intervalPerfect :: Interval -> Bool
intervalPerfect (Interval quality degree) = elem degree [0, 3, 4]
\end{code}

Convert the interval to chromatic steps.
\begin{code}
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
\end{code}

\section{Pitch Arithmetic}

Difference of two absolute chromatic pitch numbers
\begin{code}
pitchDiffChrom :: Pitch -> Pitch -> Int
pitchDiffChrom p1 p2 = pitch2pcChrom p1 - pitch2pcChrom p2
\end{code}

Increase pitch by diatonic steps
\begin{code}
pitchIncDia :: Pitch -> Int -> Pitch
pitchIncDia p n = pc2pitch (pitch2pcDia p + n) (accid p)
\end{code}

Increase pitch by @Interval@. 
The @accid@ is the difference between the diatonic sum with  accidental
and the absolute chromatic sum. 
\begin{code}
pitchInc :: Pitch -> Interval -> Pitch
pitchInc p i = 
    Pitch { 
        pnum = pnum newPitchDia, 
        oct = oct newPitchDia, 
        accid = (accid p) + (newpcChrom - pitch2pcChrom newPitchDia)
    } where
        newPitchDia = pitchIncDia p (degree i)
        newpcChrom = pitch2pcChrom p + intervalChrom i
\end{code}

\subsection{Shortcuts}
\begin{code}
pitch8va :: Pitch -> Pitch
pitch8va p = pitchIncDia p 7

pitch8vb :: Pitch -> Pitch
pitch8vb p = pitchIncDia p (-7)
\end{code}
\end{document}


