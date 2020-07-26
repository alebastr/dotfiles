_src_profile()
{
    emulate -L ksh
    # source profile
    if [ -f ~/.profile ]; then
	    source ~/.profile
    fi
}
_src_profile

unset -f _src_profile
