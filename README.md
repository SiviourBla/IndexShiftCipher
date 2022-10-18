# Index Shift Cipher
 A simple cipher written in assembly that runs on [MASM](https://en.wikipedia.org/wiki/Microsoft_Macro_Assembler)

 - Each letter's index in the alphabet is combined with all the previous indices, looping back when it reaches the end.
 - The character '@' is used to signify an index of 0, and is converted to a space when decoding.
 - Lower case letters are converted to uppercase before decoding and encoding.
 	- Spaces are replaced with '@' before decoding and encoding.
 	- All other characters are replaced with '@' before encoding.

For example:

 - AAA --> ABC
 - BBB --> BDF
 - ABC --> ACF
 - XAAAAAA --> XYZ@ABC
 - Index Shift --> IW@EBBUBKQJ
