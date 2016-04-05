This script, given a text file, returns any vocabulary mistakes found or capitalization errors.
Input file is specified during script execution and output file is called "output.txt" if not present in current directory will be created otherwise if present current file will be overwriten. 
Script uses a dictionary file located in the same directory as the script and is called "dictionary.txt".
Use of perl library Text::LevenshteinXS in order to get Levenshtein distance of two words, this library requires a C compiler which should be easy to install.
Might no work on older perl versions. 
