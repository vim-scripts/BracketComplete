" BracketComplete.vim: Insert mode completion for text inside various brackets.
"
" DEPENDENCIES:
"   - MotionComplete.vim autoload script
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	02-Oct-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

let s:openBrackets  = join(keys(g:BracketComplete_BracketConfig), '')
let s:bracketPattern = printf('[%s][^%s]*\%%#', s:openBrackets, s:openBrackets)
function! BracketComplete#Expr()
    let l:bracketCol = searchpos(s:bracketPattern, 'bnW', line('.'))[1]
    if l:bracketCol == 0
	return "\<C-\>\<C-o>\<Esc>" | " Beep.
    endif

    let l:openBracket = matchstr(getline('.'), '.', l:bracketCol - 1)
    let l:closeBracket = g:BracketComplete_BracketConfig[l:openBracket].opposite
    let l:hasCloseBracket = (search('\%#\_s*\V' . l:closeBracket, 'cnW') != 0)

    let l:textObject = get(g:BracketComplete_BracketConfig[l:openBracket], 'textobject', '')
    if empty(l:textObject)
	" There's no text object for this type of bracket. Always include the
	" opening bracket, and (multi-line-)search for the closing bracket.
	let l:startCol = l:bracketCol
	let l:motion = printf('/%s/%s',
	\   g:BracketComplete_BracketConfig[l:openBracket].opposite,
	\   (l:hasCloseBracket ? '' : 'e')
	\)
    else
	" Use the inner text object when we're just filling in text between
	" existing brackets; otherwise, include the closing bracket in the
	" match.
	let [l:startCol, l:innerOuter] = (l:hasCloseBracket ?
	\   [l:bracketCol + len(l:openBracket), 'i'] :
	\   [l:bracketCol, 'a']
	\)
	let l:motion = l:innerOuter . l:textObject

	if l:textObject ==# 't' && ! l:hasCloseBracket
	    " Special case: For the outer "a tag block" text object, detected by
	    " a ">" opening bracket, we must include the full start tag.
	    let l:startCol = searchpos('<[^<]\+>[^>]*\%#', 'bnW', line('.'))[1]
	    if l:startCol == 0
		return "\<C-\>\<C-o>\<Esc>" | " Beep.
	    endif
	endif
    endif
"****D echomsg '****' string(l:openBracket) string(l:closeBracket) l:hasCloseBracket string(l:motion)
    return MotionComplete#Expr(l:motion, [l:startCol, col('.')])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
