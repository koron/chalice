# vim:set ts=8 sts=8 sw=8 tw=0:
#
# Last Change: 14-Mar-2003.

RM	= rm -f
RMDIR	= rm -fr

tags: plugin/*.vim
	ctags plugin/*.vim

update:
	cvs -z3 update -dP

clean:
	$(RM) doc/chalice.txt
