" vim:set ts=8 sts=2 sw=2 tw=0 nowrap:
"
" alice.vim - A vim script library
"
" Last Change: 27-Jul-2002.
" Written By:  MURAOKA Taro <koron@tka.att.ne.jp>

let s:version_serial = 111
if exists('g:plugin_alice_disable') || (exists('g:version_alice') && g:version_alice > s:version_serial)
  finish
endif
let g:version_alice = s:version_serial

"------------------------------------------------------------------------------
" ALICE

function! AL_string_multiplication(base, scalar)
  " Like perl's 'x' operator
  let retval = ''
  let base = a:base
  let scalar = a:scalar
  while scalar
    if scalar % 2
      let retval = retval . base
    endif
    let scalar = scalar / 2
    let base = base . base
  endwhile
  return retval
endfunction

function! AL_sscan(string, pattern, select)
  return substitute(matchstr(a:string, a:pattern), a:pattern, a:select, '')
endfunction

function! AL_compareversion(ver1, ver2)
  " Compare version strings a:ver1 and a:ver2.  If a:ver2 indicate more
  " newer version than a:ver1 indicated, return 1.  Equal, return 0.  Older,
  " return -1.
  let mx_ver = '\d\+\%(\.\d\+\)*'
  let v1 = matchstr(a:ver1, mx_ver)
  let v2 = matchstr(a:ver2, mx_ver)
  let mx_num = '^0*\(\d\+\)\%(\.\(.*\)\)\?'
  while v1 != '' && v2 != ''
    "echo "v1=".v1." v2=".v2
    let n1 = substitute(v1, mx_num, '\1', '') + 0
    let n2 = substitute(v2, mx_num, '\1', '') + 0
    let v1 = substitute(v1, mx_num, '\2', '')
    let v2 = substitute(v2, mx_num, '\2', '')
    if n1 < n2
      return 1
    elseif n1 > n2
      return -1
    endif
  endwhile
  if (v1 == '' || v1 + 0 == 0) && (v2 == '' || v2 + 0 == 0)
    return 0
  elseif v1 == ''
    return 1
  else
    return -1
  endif
endfunction

function! AL_islastline(...)
  return line('$') == line(a:0 > 0 ? a:1 : '.')
endfunction

function! AL_selectwindow(window)
  " Specify window number from buffer name or window number.
  let num = bufwinnr(a:window)
  if num < 0 && a:window =~ '^\d\+$'
    let num = a:window + 0
    if winbufnr(num) < 0
      let num = -1
    endif
  endif
  " Activate window
  if num >= 0 && num != winnr()
    call AL_execute(num.'wincmd w')
  endif
  return num
endfunction

function! AL_setwinheight(height)
  " Change current window height
  call AL_execute('normal! '.a:height."\<C-W>_")
endfunction

function! AL_hascmd(cmd)
  let cmd = a:cmd
  " Preparing PATH for globpath
  if has('win32')
    let path = substitute(substitute($PATH, '\\', '/', 'g'), ';', ',', 'g')
    let cmd = cmd . '.exe'
  else
    let path = substitute($PATH, ':', ',', 'g')
  endif
  " Save value of 'wildignore' and reset it
  let wildignore = &wildignore
  set wildignore=
  " Search a command from path
  let cmdpath = globpath(path, cmd)
  if has('win32') && cmdpath == ''
    let retval = globpath($VIM, cmd)
  elseif cmdpath != ''
    let retval = cmd
  endif
  " Revert 'wildignore'
  let &wildignore = wildignore
  return retval
endfunction

function! AL_del_lastsearch()
  call histdel("search", -1)
endfunction

function! AL_fileread(filename)
  " Read file and return it in multi-line string form.
  if !filereadable(a:filename)
    return ''
  endif
  if has('win32') && &shell =~ '\ccmd'
    let cmd = 'type'
  else
    let cmd = 'cat'
  endif
  return AL_system(cmd . ' ' . AL_quote(a:filename))
endfunction

function! AL_chompex(str)
  " Remove leading and trailing white-spaces.
  return substitute(a:str, '^\s\+\|\s\+$', '', 'g')
endfunction

function! AL_chomp(str)
  " Like perl chomp() function.  (But did't change argument)
  return substitute(a:str, '\s\+$', '', '')
endfunction

function! AL_buffer_clear()
  call AL_execute('%delete _')
endfunction

function! AL_mkdir(dirpath)
  " Make directory and its parents if needed.
  let dirpath = AL_quote(substitute(a:dirpath, '[/\\]$', '', ''))
  if has('win32') && &shell !~ 'sh'
    call AL_system('mkdir ' . substitute(dirpath, '/', '\\', 'g'))
  else
    call AL_system('mkdir -p ' . dirpath)
  endif
endfunction

let g:AL_pattern_class_url = '[-!#$%&+,./0-9:;=?@A-Za-z_~]'

function! AL_open_url(url, cmd)
  " Open given URL by external browser
  "   For Windows, if cmd is empty, system related URL browser is used.  For
  "   all, if cmd include string '%URL%', it is replaced with url.  If not
  "   include just appended.
  let retval = 0
  if a:url == ''
    return retval
  endif
  let url = AL_verifyurl(a:url)

  if a:cmd != ''
    let url = AL_quote(url)
    if a:cmd =~ '%URL%'
      " Avoid that '&' is replaced by '%URL%'.
      " Avoid that '~' is replaced by previous replace string.
      let url = escape(url, '&~\\')
      let excmd = substitute(a:cmd, '%URL%', url, 'g')
    else
      let excmd = a:cmd . ' ' . url
    endif
    if excmd !~ '^!'
      call AL_system(excmd)
    else
      let url = escape(url, '%#')
      call AL_execute(excmd)
    endif
    let retval = 1
  elseif has('win32')
    " If 'url' has % or #, all of those characters are expanded to buffer
    " name by execute().  Below escape() suppress this.  system() does not
    " expand those characters.
    let url = escape(url, '%#')
    " Start system related URL browser
    if !has('win95') && url !~ '[&!]'
      " for Win NT/2K/XP
      call AL_execute('!start /min cmd /c start ' . url)
    else
      call AL_execute("!start rundll32 url.dll,FileProtocolHandler " . url)
    endif
    let retval = 1
  elseif has('mac')
    " Use osascript for MacOS X
    call AL_system("osascript -e 'open location \"" .url. "\"'")
    let retval = 1
  endif
  return retval
endfunction

function! AL_nr2hex(nr)
  " see :help eval-examples
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunction

function! AL_urlencoder_ch2hex(ch)
  let hex = AL_nr2hex(char2nr(a:ch))
  if strlen(hex) % 2 == 1
    let hex = '0' . hex
  endif
  return substitute(hex, '\(..\)', '%\1', 'g')
endfunction

function! AL_verifyurl(str)
  let retval = a:str
  let retval = substitute(retval, '[$~]', '\=AL_urlencoder_ch2hex(submatch(0))', 'g')
  let retval = substitute(retval, ' ', '+', 'g')
  return retval
endfunction

function! AL_urlencode(str)
  " Return URL encoded string
  let retval = a:str
  let retval = substitute(retval, '[^- *.0-9A-Za-z]', '\=AL_urlencoder_ch2hex(submatch(0))', 'g')
  let retval = substitute(retval, ' ', '+', 'g')
  return retval
endfunction

function! AL_urldecode(str)
  let retval = a:str
  let retval = substitute(retval, '+', ' ', 'g')
  let retval = substitute(retval, '%\(\x\x\)', '\=nr2char("0x".submatch(1))', 'g')
  return retval
endfunction

function! s:Uni_nr2enc_char(charcode)
  let char = nr2char(a:charcode)
  if has('iconv') && strlen(char) > 1
    let char = iconv(char, 'ucs-2le', &encoding)
    if char !~ '^\p\+$'
      let char = '?'
    endif
  endif
  return char
endfunction

function! AL_decode_entityreference_with_range(range)
  " Decode entity reference for range
  call AL_execute(a:range . 's/&gt;/>/g')
  call AL_execute(a:range . 's/&lt;/</g')
  call AL_execute(a:range . 's/&quot;/"/g')
  call AL_execute(a:range . "s/&apos;/'/g")
  call AL_execute(a:range . 's/&nbsp;/ /g')
  call AL_execute(a:range . 's/&#\(\d\+\);/\=s:Uni_nr2enc_char(submatch(1))/g')
  call AL_execute(a:range . 's/&amp;/\&/g')
endfunction

function! AL_decode_entityreference(str)
  " Decode entity reference for string
  let str = a:str
  let str = substitute(str, '&gt;', '>', 'g')
  let str = substitute(str, '&lt;', '<', 'g')
  let str = substitute(str, '&quot;', '"', 'g')
  let str = substitute(str, '&apos;', "'", 'g')
  let str = substitute(str, '&nbsp;', ' ', 'g')
  let str = substitute(str, '&#\(\d\+\);', '\=s:Uni_nr2enc_char(submatch(1))', 'g')
  let str = substitute(str, '&amp;', '\&', 'g')
  return str
endfunction

function! AL_get_quotesymbol()
  " Return quote symbol.
  if &shellxquote == '"'
    return "'"
  else
    return '"'
  endif
endfunction

function! AL_quote(str)
  " Quote filepath by quote symbol.
  let fq = AL_get_quotesymbol()
  retur fq . a:str. fq
endfunction

"------------------------------------------------------------------------------
" FLAG OPRATION

function! AL_delflag(flags, flag)
  let newflags = substitute(a:flags, '\(^\|,\)' .a:flag. '\(,\|$\)', ',', 'g')
  let newflags = substitute(newflags, ',,\+', ',', 'g')
  let newflags = substitute(newflags, '^,', '', 'g')
  let newflags = substitute(newflags, ',$', '', 'g')
  return newflags
endfunction

function! AL_addflag(flags, flag)
  return AL_hasflag(a:flags, a:flag) ? a:flags : (a:flags == '' ? a:flag : a:flags .','. a:flag)
endfunction

function! AL_hasflag(flags, flag)
  " Return 1 (not 0) if a:flags has word a:flag.  a:flags is supposed a list
  " of words separated by camma as CSV.
  return a:flags =~ '\(^\|,\)' . a:flag .'\(,\|$\)'
endfunction

"------------------------------------------------------------------------------
" MULTILINE STRING

function! AL_getline(multistr, linenum)
  if a:linenum == 0
    return AL_firstline(a:multistr)
  else
    return substitute(a:multistr, "^\\%([^\<NL>]*\<NL>\\)\\{" . a:linenum . "}\\([^\<NL>]*\\).*", '\1', '')
  endif
endfunction

function! AL_countlines(multistr)
  if a:multistr == ''
    return 0
  else
    return strlen(substitute(a:multistr, "[^\<NL>]*\<NL>\\?", 'a', 'g'))
  endif
endfunction

function! AL_lastlines(multistr)
  let nextline = matchend(a:multistr, "^[^\<NL>]*\<NL>\\?")
  return strpart(a:multistr, nextline)
endfunction

function! AL_firstline(multistr)
  return matchstr(a:multistr, "^[^\<NL>]*")
endfunction

"------------------------------------------------------------------------------
" WRAPPER

function! AL_execute(cmd)
  if 0 && exists('g:AL_option_nosilent') && g:AL_option_nosilent != 0
    execute a:cmd
  else
    silent! execute a:cmd
  endif
endfunction
command! -nargs=1 ALexecute		call AL_execute(<args>)

function! AL_system(cmd)
  " system() wrapper function
  let cmdstr = a:cmd
  if has('win32') && &shell =~ '\ccmd'
    let cmdstr = '"' . cmdstr . '"'
  endif
  return system(cmdstr)
endfunction
command! -nargs=1 ALsystem		call AL_system(<args>)
