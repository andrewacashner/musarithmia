musarithmia
----------
----------

Projects by a professional musician and amateur programmer.
I welcome your feedback, andrewacashner at gmail.

Copyright (c) 2015 Andrew A. Cashner.

`interval`
---------

*`interval`* calculates musical intervals.

This program is written in Donald Knuth and Silvio Levy's `CWEB` system.
To compile the `.w` file, you will need the programs `CTANGLE` which produces a
C program, and `CWEAVE`, which produces a `.tex` file which when processed with
TeX, will give a PDF with the documentation and the program together.

The simplest way to acquire these is from the TeXlive distribution from the TeX
User's Group (<http://www.tug.org/>).

In a console, run the following commands for a CWEB file called `file.w`:

    ctangle file
    gcc file (or C compiler of choice)
    cweave file
    pdftex file

