/title/ {
	s = $0
	split(s, h1, /[<]\/?title>/)
	split(h1[2], h2, " ")
	printf("%s", h2[4])
} 
