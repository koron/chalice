" vim:set ts=8 sts=2 sw=2 tw=0 nowrap:
"
" alice.vim - A vim script library
"
" Last Change: 11-May-2002.
" Written By:  MURAOKA Taro <koron@tka.att.ne.jp>

let s:version_serial = 101

if exists('plugin_alice_disable') || (exists('g:alice_version') && g:alice_version > s:version_serial)
  finish
endif
let g:alice_version = s:version_serial

"------------------------------------------------------------------------------
" ALICE

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
  return substitute(a:str, '^\s\+\|\s\+$', '', '')
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

function! AL_open_url(url, cmd)
  " Open given URL by external browser
  "   For Windows, if cmd is empty, system related URL browser is used.  For
  "   all, if cmd include string '%URL%', it is replaced with url.  If not
  "   include just appended.
  let retval = 0
  if a:url == ''
    return retval
  endif
  if a:cmd != ''
    " Avoid that '&' is replaced by '%URL%'.
    " Avoid that '~' is replaced by previous replace string.
    let url = AL_quote(a:url)
    if a:cmd =~ '%URL%'
      let url = escape(url, '&~\\')
      let excmd = substitute(a:cmd, '%URL%', url, 'g')
    else
      let excmd = a:cmd . ' ' . url
    endif
    call AL_system(excmd)
    let retval = 1
  elseif has('win32')
    " If 'url' has % or #, all of those characters are expanded to buffer
    " name by execute().  Below escape() suppress this.  system() does not
    " expand those characters.
    let url = escape(a:url, '%#')
    " Start system related URL browser
    if !has('win95') && url !~ '[&!]'
      " for Win NT/2K/XP
      call AL_execute('!start /min cmd /c start ' . url)
    else
      call AL_execute("!start rundll32 url.dll,FileProtocolHandler " . url)
    endif
    let retval = 1
  elseif has('macos')
    " TODO: Implement MacOS X specified command
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

function! AL_urlencode(str)
  " Return URL encoded string
  let encstr = substitute(a:str, '\([^- *.0-9A-Za-z]\)', '\=AL_urlencoder_ch2hex(submatch(1))', 'g')
  let encstr = substitute(encstr, ' ', '+', 'g')
  return encstr
endfunction

function! AL_decode_entityreference(range)
  " Decode entity reference
  call AL_execute(a:range . 's/&gt;/>/g')
  call AL_execute(a:range . 's/&lt;/</g')
  call AL_execute(a:range . 's/&quot;/"/g')
  call AL_execute(a:range . "s/&apos;/'/g")
  call AL_execute(a:range . 's/&nbsp;/ /g')
  call AL_execute(a:range . 's/&#\(\d\+\);/\=nr2char(submatch(1))/g')
  call AL_execute(a:range . 's/&amp;/\&/g')
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
