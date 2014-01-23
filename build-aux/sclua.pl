#!/usr/bin/perl -wnl
use strict;
my ($nfailure) = 0;

my (@lua_global_functions) = qw(assert collectgarbage dofile error
    getmetatable ipairs load loadfile next pairs pcall print rawequal rawget
    rawlen rawset require select setmetatable tonumber tostring type
    xpcall);

my ($match_lua_global_function);
do {
    local $,='';
    $match_lua_global_function = join '|', @lua_global_functions;
};

my (@lua_global_modules) = qw(bit32 coroutine debug io math
    os package string table);

my ($match_lua_global_module);
do {
    local $,='';
    $match_lua_global_module = join '|', @lua_global_modules;
};

sub _fail {
    my ($file, $line, $msg) = @_;
    defined $file and length $file > 0 and $file = "$file:" or $file = '';
    defined $line and $line > 0 and $line = "$line:" or $line = '';
    warn "error:$file$line $msg\n";
    ++$nfailure;
}

sub fail {
    my ($msg) = @_;
    _fail $ARGV, $., $msg;
}

sub fail_at {
    my ($msg) = @_;
    _fail $ARGV, $., "$msg\n-->$_";
}

sub match {
    my ($pattern, $file) = @_;
    local $.;
    open (FP, '<', $file) or die $!;
    my (@lines) = <FP>;
    close FP or warn $!;
    return grep /$pattern/, @lines;
}

sub function_is_used {
    my ($func, $file) = @_;
    return match qr/\b$func\s*\(/, $file;
}

sub module_is_used {
    my ($mod, $file) = @_;
    return match qr/\b$mod[\.\[]/, $file;
}

/\t/g
    and fail_at "don't use tabs";

/.*(\s+)$/ and ($1 ne "\cL" or length $_ > 1)
    and fail_at "trailing white-space";

/^\s*::\s+\w+\s+::/
    and fail_at "useless space between :: and goto label";

/^\s*require\b/
    and fail_at "require() without assignment";

/^\s*(print|module)\s*\(.*?\)/
    and fail_at "don't use $1() in \"real\" code";

/^(\w+)\s*(,\s*\w+\s*)*=/ and $1 ne '_ENV'
    and fail_at "don't use global variables";

/^function\s*\w+\s*\(/
    and fail_at "don't use global functions";

/^\s*local\s+($match_lua_global_function)\s+=\s+\1\b/
    and !function_is_used "$1", $ARGV
    and fail_at "$1() declared but not used";

/^\s*local\s+($match_lua_global_module)\s+=\s+\1\b/
    and !module_is_used "$1", $ARGV
    and fail_at "$1 module declared but not used";

eof and do {
    !match qr/^\s*_ENV\s*=\s*nil\b/, $ARGV
        and fail "missing '_ENV=nil'", '';

    do {
        local $.;
        open FP, '<', $ARGV or die $!;
        my ($p) = sysseek (FP, -2, 2);
        my ($last_two_bytes);
        defined $p and $p = sysread FP, $last_two_bytes, 2;
        close FP;
        $p and ($last_two_bytes eq "\n\n"
                or substr ($last_two_bytes, 1) ne "\n")
            and fail "empty line(s) or no newline at EOF";
    };

    close ARGV;
};

END {
    $nfailure > 0 and exit 255;
}
