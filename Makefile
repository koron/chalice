# vim:set ts=8 sts=8 sw=8 tw=0:
#
# Last Change: 21-May-2002.

RM	= rm -f
RMDIR	= rm -fr

tags: plugin/*.vim
	ctags plugin/*.vim

clean:
	$(RM) doc/chalice.txt
#	$(RMDIR) chalice.d
