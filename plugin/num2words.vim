if exists("g:loaded_num2words") || v:version < 700
	finish
endif
let g:loaded_num2words = 1

command! Num2Words call num2words#replace()
command! Num2CCY call num2words#replace("CCY")
