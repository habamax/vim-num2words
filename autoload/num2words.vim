
let s:dig1 = ["один", "два", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять" ]
let s:dig1f = ["одна", "две", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять" ]
let s:dig10 = ["десять", "одиннадцать", "двенадцать", "тринадцать", "четырнадцать", "пятнадцать", "шестнадцать", "семнадцать", "восемнандцать", "девятнадцать" ]
let s:dig20 = ["двадцать", "тридцать", "сорок", "пятьдесят", "шестьдесят", "семдесят", "восемьдесят", "девяносто" ]
let s:dig100 = ["сто", "двести", "триста", "четыреста", "пятьсот", "шестьсот", "семьсот", "восемьсот", "девятьсот" ]
let s:levels = [
			\ ["", "", ""],
			\ ["тысяча", "тысячи", "тысяч"],
			\ ["миллион", "миллиона", "миллионов"],
			\ ["миллиард", "миллиарда", "миллиардов"],
			\ ["триллион", "триллиона", "триллионов"]
			\ ]

"" call num2words#convert(12342)
"" returns list of lists
"" [['двенадцать','тысяч'], ['триста', 'сорок', 'два']]
func! num2words#convert(num, ...) abort
	let result = get(a:, 1, [])
	let level = get(a:, 2, 0)


	if a:num == 0 && level == 0
		return ['ноль']
	endif

	let level_result = []

	let h = a:num%1000
	let d = h/100
	if d > 0
		call add(level_result, s:dig100[d-1])
	endif

	let n = h%100
	let d = n/10
	let n = n%10

	if d == 1
		call add(level_result, s:dig10[n])
		let n = 0
	endif

	if d > 1
		call add(level_result, s:dig20[d-2])
	endif

	if n != 0
		if level != 1
			call add(level_result, s:dig1[n-1])
		else
			call add(level_result, s:dig1f[n-1])
		endif
	endif

	if level > 0
		if n == 0 || n > 4
			call add(level_result, s:levels[level][2])
		elseif n == 1
			call add(level_result, s:levels[level][0])
		else
			call add(level_result, s:levels[level][1])
		endif
	endif

	call add(result, level_result)

	let next_num = a:num/1000
	if next_num > 0
		return num2words#convert(next_num, result, level+1)
	else
		return reverse(result)
	endif

endfunc

func! num2words#ccy(num) abort
	let result = 'рублей'
	let n = a:num%10
	if n == 1
		let result = 'рубль'
	elseif n < 5
		let result = 'рубля'
	endif
	return result
endfunc

func! num2words#replace() abort
	let number = s:get_number()
	if !number.is_num
		echom "[" number.num "] is not a number"
		return
	endif

	let words = join(s:flatten(num2words#convert(number.num)))
	let line = getline('.')
	call setline('.',
				\ strpart(line, 0, number.start)
				\ .
				\ words
				\ .
				\ strpart(line, number.end+1))
endfunc


"" Helper functions {{{1

func! s:get_number() abort
	let line = getline('.')
	let col = getpos('.')[2]
	let start = col
	let end = col

	while start > 0
		if !s:is_number(line[(start-1):end])
			break
		endif
		let start -= 1
	endwhile
	while end < strwidth(line)
		if !s:is_number(line[start:(end+1)])
			break
		endif
		let end += 1
	endwhile

	let word = line[start:end]
	return {"is_num": s:is_number(word), "num": word, "start": start, "end": end}
endfunc

func! s:is_number(num) abort
	return a:num =~# '^\d\+$'
endfunc

func! s:flatten(list) abort
	let val = []
	for elem in a:list
		if type(elem) == type([])
			call extend(val, s:flatten(elem))
		else
			call add(val, elem)
		endif
		unlet elem
	endfor
	return val	
endfunc

