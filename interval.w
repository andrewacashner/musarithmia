% This program is copyright (c) 2015 Andrew A. Cashner.
%
% v0	2015-04-12	First working prototype
% v1	2015-04-20	Improved

\def\title{Interval Calculator}
\def\emph #1{\bgroup\it#1\/\egroup}
\def\term{\emph}
\def\q#1{``#1''}

@* Introduction.
This is \.{interval}, a program to calculate musical intervals by Andrew
Cashner, \today.  
The user provides a command in the form of (1) a starting pitch with its octave
and accidental, and (2) an interval degree and quality to add or subtract.
The program outputs an ending pitch with its octave and accidental.

Musical pitches are grouped in octaves, which are divided into seven 
\term{pitch classes} constituting the \term{diatonic series}.
These are lettered C, D, E, F, G, A, B, where each new octave starts
with C, and where these names (with no accidental) match the white keys on the
piano.
We assign each pitch class a number, where C is 0 and B is 6.
(A \term{pitch class} is, for example, all notes named C, regardless of their
octave).

There are twelve semitones in each octave, constituting the \term{chromatic
series}.
The diatonic pitches are spaced at intervals of semitones and tones in an
asymmetrical pattern (the intervals in an octave from C to C are 
T--T--ST--T--T--T--ST).
Each diatonic pitch therefore has a chromatic code corresponding to its distance
in semitones from C natural: the series is 0, 2, 4, 5, 7, 9, 11 for C through B.

The whole series of diatonic pitches may be mapped to index numbers starting
with C$_0$---these are the \term{absolute diatonic pitch numbers}.
The octave number and pitch-class number may be thought of as two digits of a
base-7 number: the octave number is the \q{sevens} digit, and the pitch-class
number is the \q{ones} digit.
The absolute diatonic pitch number is a decimal representation of that base-7
number.
For example, \q{middle C} is C$_4$; so the pair $\{octave, pitch class\}$
is $\{4, 0\}$. 
Since $7 * 4 + 0 = 28$, C$_4$ has the absolute diatonic pitch number 28.

The whole series of \emph{chromatic} pitches may also be mapped to index numbers
starting with C$_0$---these are the \term{absolute chromatic pitch numbers}.
Now the pair of octave and pitch-class number correspond to the two digits of a
base-\emph{twelve} number, which we can convert to a decimal representation to
get the absolute chromatic pitch number.
For middle C, the pair $\{4, 0\}$, since $12 * 4 + 0 = 48$, the absolute
chromatic pitch number is 48.

To calculate the end pitch class and octave, first we convert the start octave
and pitch class (taken as two digits of a base-seven number) into decimal form.
The given interval degree (minus one since we count from zero) is also diatonic,
so we add it to the absolute diatonic pitch-class number to get the end absolute
diatonic pitch-class number. 
To get the end octave and pitch class, we convert the decimal number back to the
two base-seven digits: the \q{sevens} become the octave and the \q{ones} become
the pitch class.

Calculating the end accidental is more complicated because we must use the
chromatic series.
The codes for the accidentals are $-1$ for flat, 0 for natural, and $+1$ for
sharp.
The end-accidental code is the difference between the ending absolute chromatic
pitch number and the absolute chromatic pitch number of the ending \emph{base 
pitch}. 
If the end pitch is calculated to be absolute chromatic pitch number 49,
enharmonically this could correspond to several pitch names (e.g., C$\sharp$ 
or D$\flat$). 
From the diatonic calculation already discussed, we know in this example that
the \emph{base diatonic pitch} is C.
So the end accidental is the difference between 49 and the absolute chromatic
pitch number of C$\natural$ (48).
The result is $+1$, so the end note is C$\sharp$.

To calculate the absolute chromatic pitch number of the end note, we first
calculate the chromatic pitch number of the start note, by treating the pair
$\{octave, pitch class\}$ as two digits in base 12, and converting to a decimal
representation of this base-12 number.
To this we add the code for the start accidental.
So C$\sharp_4$ is $12 * 4 + 0 + 1 = 49$.

Next we need to add the chromatic interval, the number of chromatic steps.
For this we need to convert the diatonic interval to a chromatic interval and
then add the code for the interval quality.
(In the input routine we test for proper matches of interval degree and interval
quality---thirds cannot be perfect and fifths cannot be major, for example.)
The diatonic interval is already the decimal version of a base-seven diatonic
interval, so we must obtain the pair $\{octave, pitch class\}$, 
and then use functions to convert that to the decimal representation of a
base-\emph{twelve} number. 
To that we add the interval-quality code.
Adding the chromatic interval to the start chromatic pitch number we get the
ending absolute chromatic pitch number.
We use that to calculate the end accidental.

For example, we convert the interval of a minor ninth (code 8) as follows:
8 (decimal representation of base-7 number) converts to the pair $\{1,1\}$.
We convert the \q{ones} digit to a chromatic code using the chromatic series
described earlier: 1 diatonic step equals 2 semitones in the chromatic series.
So that pair converts to decimal representation of base-12 as $12 * 1 + 2 = 14$.

We convert the integer values back to the proper character symbols and output
the results.

@p
#include <stdio.h>
#include <stdlib.h>
@#
@<Constants@>@;
@<Global variables@>@;
@<Function prototypes@>@;
@#
int main(int argc, char *argv[]) 
{
	@<Main variables@>@;
	@<Validate and store input@>@;
	@<Compute diatonic end pitch and octave@>@;
	@<Compute end accidental@>@; 
	@<Print output@>@;
	return(0);
}

@ These constant arrays allow us to encode and decode accidentals and interval qualities.
|dia_to_chrom| allows conversion between diatonic and chromatic pitch classes
and interval qualities.  
There are pairs of arrays for the accidental and interval quality.
There is no need to use a |struct| because we can easily access them by name and
array index.

The diminished interval quality for an imperfect interval is actually $-2$;
during the input validation we test for imperfect intervals, and if imperfect
and diminished, we decrease the |interval_quality| by 1.

@<Constants@>=

static const int dia_to_chrom[] = {0, 2, 4, 5, 7, 9, 11}; 
/* $ C = 0, D = 2, \dots, B = 11 $ */
@#
static const int accidental_code[] = {-2, -1, 0, 1, 2};
static const char accidental_name[] = {'B', 'b', 'n', 's', 'X'};
@#
static const int interval_quality_code[] = {-1, -1, 0, 0, 1};
static const char interval_quality_name[] = {'d', 'm', 'M', 'P', 'a'};
@#
@<Error message strings@>@;

@ We use the boolean switch |found| for scanning through the constant arrays to find a match.
We use |perfect_interval| to mark the interval quality for testing.

@<Global variables@>=
typedef enum { FALSE, TRUE } boolean;
boolean found;
boolean perfect_interval;

@* Functions for converting to and from base ten.

@ Function: Convert decimal number to pair of digits in a given base.
The function receives the addresses of |int| variables used in the main routine.

@<Function prototypes@>=
void convert_from_base_ten(int base, int input, int *main_tens, int *main_ones);

@ The function does the same thing as the following, but at lower cost:
| ones = input % base; tens = input / base; |

@p
void convert_from_base_ten(int base, int input, int *main_tens, int *main_ones)
{
	int tens, ones;
	tens = 0;
	ones = input;
	while (ones > base) {
		ones -= base;
		++tens;
	}
	*main_tens = tens;
	*main_ones = ones;
	return;
}

@ Function: The reverse, convert a pair of digits in a given base to a decimal number.

@<Function prototypes@>=
int convert_to_base_ten(int base, int multiples, int ones);

@ The |multiples| are the \q{bases} columns (\q{tens} in base ten).

@p
int convert_to_base_ten(int base, int multiples, int ones)
{
	int result;
	result = base * multiples + ones;
	return(result);
}


@* Process input.
There are six arguments required for a valid interval-calculation command:

\def\ttchar #1{%
	{\tt '#1'}\ %
}

\item{1.} pitch-class name (\ttchar{C}, \ttchar{D}, \ttchar{E},
\ttchar{F}, \ttchar{G}, \ttchar{A}, \ttchar{B})
\item{2.} accidental (\ttchar{s} for sharp, \ttchar{n} for natural,
\ttchar{b} for flat; \ttchar{X} for double sharp; \ttchar{B} for double flat)
\item{3.} octave number (\ttchar{0}--\ttchar{20}), where middle C is octave 4
\item{4.} operator (\ttchar{+} or \ttchar{-})
\item{5.} interval quality (\ttchar{M} for major, \ttchar{m} for minor,
\ttchar{P} for perfect, \ttchar{a} for augmented, \ttchar{d} for diminished)
\item{6.} interval degree (\ttchar{1}--\ttchar{70})

@s operator text

@<Main variables@>=
int i; /* Loop counter */
int start_pitchclass; /* Integer 0--6 representing pitch C--B */
int start_accidental; /*  From |accidental_code| */
int start_octave; /* Octave number of starting pitch  */
int operator; /* -1 if '-', +1 if '+' */
int interval_quality; /* From |interval_quality_code| */
char interval_quality_name_in; /* Character input, should match one of |interval_quality_name| */
int interval_dia; /* The absolute diatonic interval, one less than input (e.g., a tenth becomes 9) */

@ Check each argument for valid input; if valid, store it in the proper format (everything becomes an |int| code). 
If not, exit with specific error message (called up from |error| array of strings).

For the pitch name, we convert the character into an |int| 0--7, where C is 0.
This means we have to adjust A and B to the end of the scale.


@<Validate and store input@>=
@<Check number of arguments@>@;
@<Get pitch class@>@;
@<Get accidental@>@;
@<Get octave number@>@;
@<Get operator@>@;
@<Get interval quality@>@;
@<Get interval number@>@;
@<Check perfect vs. imperfect interval@>@;

@ There must be seven arguments. 

@<Check number of arguments@>=
if (argc != 7) {
	exit_error(ERROR_ARGNUM, NULL);
}

@ The pitch class must be entered as an uppercase character A--G.
We convert this to an |int| code using the ASCII codes. 
Since C is 0, we wrap A and B around to the end of the series.

@<Get pitch class@>=
if (argv[1][1] != '\0' || argv[1][0] < 'A' || argv[1][0] > 'G') {
	exit_error(ERROR_PITCH, argv[1]);
}
start_pitchclass = (int)argv[1][0] - 'C';
if (start_pitchclass < 0) { /* Adjust for A or B */
	start_pitchclass += 7;
}

@ We check for valid accidental input and convert to |int| code by matching the
index of |accidental_name| to |accidental_code|.

@<Get accidental@>=
if (argv[2][1] != '\0') {
	exit_error(ERROR_ACCIDENTAL, argv[2]);
}
for (i = 0, found = FALSE; accidental_name[i] != '\0'; ++i) {
	if (argv[2][0] == accidental_name[i]) {
		found = TRUE;
		start_accidental = accidental_code[i];
		break;
	}
}
if (found == FALSE) {
	exit_error(ERROR_ACCIDENTAL, argv[2]);
}

@ Scan octave number and make sure it is within range.

@<Get octave number@>=
sscanf(argv[3], "%d", &start_octave);
if (start_octave < 0 || start_octave > 20) {
	exit_error(ERROR_OCTAVE, argv[3]);
}

@ The code for the operator is $-1$ or $+1$ depending on the input.

@<Get operator@>=
if (argv[4][1] != '\0') {
	exit_error(ERROR_OPERATOR, argv[4]);
} else {
	switch (argv[4][0]) {
		case '-':
			operator = -1;
			break;
		case '+':
			operator = 1;
			break;
		default:
			exit_error(ERROR_OPERATOR, argv[4]);
	}
}

@ As with the accidental, we convert interval quality character input
to |int| code using constant array |interval_quality_code|.

@<Get interval quality@>=
if (argv[5][1] != '\0') {
	exit_error(ERROR_INTERVAL_QUALITY, argv[5]);
}
for (i = 0, found = FALSE; interval_quality_name[i] != '\0'; ++i) {
	if (argv[5][0] == interval_quality_name[i]) {
		found = TRUE;
		interval_quality_name_in = argv[5][0];
		interval_quality = interval_quality_code[i];
		break;
	}
}
if (found == FALSE) {
	exit_error(ERROR_INTERVAL_QUALITY, argv[5]);
}

@ Get the interval number, check the range, and subtract one since we count
from zero.

@<Get interval number@>=
sscanf(argv[6], "%d", &interval_dia);
if (interval_dia < 1 || interval_dia > 70) {
	exit_error(ERROR_INTERVAL_DEGREE, argv[6]);
}
--interval_dia; /* Interval entered as \.{'10'} really means add 9 */

@ Check perfect vs. imperfect interval.

@<Main variables@>=
int interval_octaves; /* Number of octaves in interval (the \q{multiples} digit
of the interval in base 7 */
int interval_steps_dia; /* Diatonic steps in the interval in addition to octaves
(the \q{ones} digit of the interval in base 7 */

@ The interval quality and interval degree must agree; the perfect intervals
(unison, fourth, fifth) can only have perfect, augmented, and diminished
qualities, and the imperfect intervals cannot have perfect quality.  
Imperfect intervals with diminished quality have $-2$ value, versus $-1$ for
diminished perfect intervals.

We convert the input interval to |interval_octaves| and |interval_steps_dia|,
the two base-7 digits, and test |interval_steps_dia|. 
We will use both variables later when computing the |end_accidental|.

@<Check perfect vs. imperfect interval@>=
interval_octaves = interval_steps_dia = 0;
convert_from_base_ten(7, interval_dia, &interval_octaves, &interval_steps_dia);
@#
switch (interval_steps_dia) { /* Test for perfect vs. imperfect interval */
	case 0:
	case 3:
	case 4:
		perfect_interval = TRUE;
		break;
	default:
		perfect_interval = FALSE;
}
if (perfect_interval == TRUE) { /* Perfect interval, cannot be \.{'m'} or \.{'M'} */
	switch (interval_quality_name_in) {
		case 'm':
		case 'M':
			exit_error(ERROR_MISMATCH_INTERVAL_QUALITY, NULL);
			break;
		default:
			/* Do nothing */ ;
	}
} else { /* Imperfect interval: Cannot be \.{'P'}, if \.{'d'} then value should be one less */
	switch (interval_quality_name_in) {
		case 'P':
			exit_error(ERROR_MISMATCH_INTERVAL_QUALITY, NULL);
			break;
		case 'd':
			--interval_quality; /* Imperfect diminished $= -2$ */
			break;
		default:
			/* Do nothing */ ;
	}
}




@* Compute the diatonic end pitch and octave.

@<Main variables@>=
int start_abs_pitch_dia; /* Starting diatonic pitch: Absolute diatonic pitch number, base 10 */
int end_abs_pitch_dia; /* Ending diatonic pitch number */
int end_pitchclass;
int end_octave;

@ Get starting absolute diatonic pitch number, add the interval, convert back to
base-seven pair of octave and pitchclass.

@<Compute diatonic end pitch...@>=
start_abs_pitch_dia = convert_to_base_ten(7, start_octave, start_pitchclass);
end_abs_pitch_dia = start_abs_pitch_dia + operator * interval_dia;
end_pitchclass = end_octave = 0; /* Initialize before passing to function */
convert_from_base_ten(7, end_abs_pitch_dia, &end_octave, &end_pitchclass);

if (end_octave < 0) {
	exit_error(ERROR_OCTAVE_RANGE, NULL);
}
if (end_pitchclass < 0 || end_pitchclass > 6) {
	exit_error(ERROR_ENDPITCH_RANGE, NULL);
}

@* Compute the end accidental.

@<Main variables@>=
int end_accidental; /* |accidental_code| of ending accidental */
int start_abs_pitch_chrom; /* Absolute chromatic number of starting pitch */
int end_abs_pitch_chrom; /* Same for ending pitch */
int end_base_pitch_chrom; /* Abs. chromatic number of ending \emph{base} pitch
 (e.g., if end is C$\sharp$, base pitch is C$\natural$) */
int interval_chrom; /* Chromatic interval (number of semitones) */

@ We compute the end accidental by first calculating the number of the starting
pitch in a base-12 chromatic system.  
We convert the diatonic pitch to chromatic using the constant array |dia_to_chrom|.

To this we add a chromatic interval computed from the interval degree, adjusted
by the interval quality.  
First we use |dia_to_chrom| again to calculate the chromatic interval degree.

The end accidental is the difference between the end chromatic pitch calculated
this way (module 12) and the chromatic equivalent of the end diatonic pitch.

For example, C$\sharp_1$ is chromatic pitch number 13. C$\sharp_1 - m2$ should
B$\sharp_0$. 
The end chromatic pitch number is 12, and since $ 13 - 12 = 1 $, the end
accidental code is 1, or sharp. 
This accidental is added to the base diatonic pitch, already calculated to be B.

@<Compute end accidental@>=
start_abs_pitch_chrom = 
	convert_to_base_ten(12, start_octave, dia_to_chrom[start_pitchclass]) 
	+ start_accidental;
@#
interval_chrom = 
	convert_to_base_ten(12, interval_octaves, 
			dia_to_chrom[interval_steps_dia]) + interval_quality;
@#
end_abs_pitch_chrom = start_abs_pitch_chrom + operator * interval_chrom;
@#
end_base_pitch_chrom = 
	convert_to_base_ten(12, end_octave,
			dia_to_chrom[end_pitchclass]);
@#
end_accidental = end_abs_pitch_chrom - end_base_pitch_chrom;

@* Return output.

We convert the pitch class code back to a char by adding it to \.{'C'}.
A and B must be converted to negative numbers by subtracting 7.

@<Main variables@>=
char end_pitchclass_symb;
char end_accidental_symb;

@ We convert accidental codes to characters by indexing the array | accidental_name | by | end_accidental + 2 |.

@<Print output@>=
end_accidental += 2;
if (end_accidental < 0 || end_accidental > 4) {
	exit_error(ERROR_ENDACCIDENTAL_RANGE, NULL);
}
if (end_pitchclass > 4) {
	end_pitchclass -= 7;
}
end_pitchclass_symb = (char)(end_pitchclass + 'C');
end_accidental_symb = accidental_name[end_accidental];

printf("%c %c %d\n", end_pitchclass_symb, end_accidental_symb, end_octave);

@* Error messages.
These are the error messages to print before exiting; they are indexed by the |enum| labels.

@<Error message strings@>=
static const char *error[] = {
	"There must be six arguments after the program name.\n"
		"Usage: interval <pitch class> <accidental> <octave> <+ or -> <interval quality> <interval degree>\n",
	"Incorrect pitch name '%s'. Should be letter A-G.\n",
	"Accidental can only be 'B', 'b', 'n', 's', or 'X'. You entered '%s'.\n",
	"Octave number must be between 0 and 20. You entered '%s'.\n",
	"Operator must be + or -. You entered '%s'.\n",
	"Interval quality can only be 'd', 'm', 'M', 'P', or 'a'. You entered '%s'.\n",
	"Interval degree must be between 1 and 70. You entered '%s'.\n",
	"Mismatch of interval quality and degree. 'P' not allowed with imperfect intervals; 'm', 'M' not allowed with perfect.\n",
	"Result octave cannot be lower than 0. Calculation stopped.\n",
	"Computation error: Result pitchclass is out of range.\n",
	"Computation error: End accidental is out of range.\n"
};
static const enum { 
	ERROR_ARGNUM, ERROR_PITCH, ERROR_ACCIDENTAL, ERROR_OCTAVE, 
	ERROR_OPERATOR, ERROR_INTERVAL_QUALITY, ERROR_INTERVAL_DEGREE,
	ERROR_MISMATCH_INTERVAL_QUALITY, ERROR_OCTAVE_RANGE,
	ERROR_ENDPITCH_RANGE, ERROR_ENDACCIDENTAL_RANGE
} error_msg;

@ Function: Exit with an error message.

@<Function prototypes@>=
void exit_error(int msg_code, char *arg);

@ The function prints an error message from the array of |error| strings and
exits.

@p
void exit_error(int msg_code, char *arg)
{
	fprintf(stderr, error[msg_code], arg);
	exit(EXIT_FAILURE);
}


