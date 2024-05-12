set #0 to 3 if inputs are the same; set #1 to 3 if not
,>,< Get input
[>>>+>+<<<<-]>>>>[<<<<+>>>>-] copy #0 to #3
<<<[>>-<<-] #3 m= #1
>>>>+>>+ set boolan flags at #5 and #7
<<<<[>]>> if #5:
[<<<+++>>>->] #2 p= 3 & clear #5
<<<[-]>> clear #3
[>]> if #7
[<<<<+++>>>] #3 p= 3
<<<[<<+>>-] move #3 to #1
<<<[-]>>[<<+>>-] move #2 to #0