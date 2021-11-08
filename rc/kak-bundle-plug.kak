#PP:IN
eval -- %sh{ set -u
  compile() {
    echo >&2 'kak-bundle-plug: compiling'
    #cp "$1" "$2"
    local global_rewrite; global_rewrite='my $p=q(@E@);
      s/${p}-/kak-bundle-plug-/g; s/${p}_/kak_bundle_plug_/g;
      s/${p}:-/kak-bundle-plug/g;
    '
    PERL_UNICODE=SDA exec perl -- - "$1" "$global_rewrite" >"$2" <<'EOPERL'
use strict; use warnings; use autodie; use v5.28.0; use Carp; use Data::Dumper;
my ($src, $global_rewrite) = @ARGV;
{ local $/; open my $fh, q[<], $src; $src = <$fh>; close $fh; }
my $code; my $compiled;
$_ = $src;
{ eval $global_rewrite; }
s/^#PP:IN/\$code = <<'PLEOKAK';/gm;
s/^#PP:(OUT|IGN.*)/PLEOKAK/gm;
s/^#PP:COPY\b(.*)/PLEOKAK\n$1\n\$compiled .= \$code;/gm;
s/^#PP:CODE//gm;
$src = $_;
#{ open my $fh, q[>], q[/tmp/kakinv.pl]; print $fh $src; }
eval $src; print $compiled;
EOPERL
  }
  set -- "$kak_source"
  case "$1" in (*.compiled)
    echo 'fail %{kak-bundle-plug: compiler failure}'; return 1
  esac
  set -- "$1" "$1".compiled; echo "source %\"$2\""
  if [ -e "$2" ] && [ "$2" -nt "$1" ] && ! [ "$2" -ot "$2" ]; then :
  else compile "$@"
  fi
}; echo -debug %{kak-bundle-plug: compiled version loaded}
nop -- %{
#PP:IGNORE
#PP:IN

def @E@:- -params 1.. -docstring %{
  Partially emulates plug.kak using kak-bundle
  Args: [ {URL|CMD} POST-LOAD plug]..
    POST-LOAD: {
      config CFG |
      {demand|defer} MODNAME POST-REQUIRE |
      load-path PATH
    }
} %{
  set global @E@_cmd
  @E@-0 %arg{@}
  bundle-register-and-load %opt{@E@_cmd}
} -override


## kakscript library

decl -hidden str      kak_bundle_plug_str
decl -hidden str-list kak_bundle_plug_slist
decl -hidden str-list kak_bundle_plug_test_slist
decl -hidden str-list kak_bundle_plug_code_slist
decl -hidden str      kak_bundle_plug_code_str
decl -hidden str-list kak_bundle_plug_args

def kak-bundle-plug-true  -params 2 %{ eval %arg{1} } -override -hidden
def kak-bundle-plug-false -params 2 %{ eval %arg{2} } -override -hidden
def kak-bundle-plug-if    -params 3 %{ %arg{@} } -override -hidden

def kak-bundle-plug-rep-opt-2 -params 1 %{
  eval "set -add global %arg{1} %%opt{%arg{1}}"
} -override -hidden
def kak-bundle-plug-rep-opt-4 -params 1 %{
  kak-bundle-plug-rep-opt-2 %arg{1}
  kak-bundle-plug-rep-opt-2 %arg{1}
} -override -hidden
def kak-bundle-plug-rep-opt-8 -params 1 %{
  kak-bundle-plug-rep-opt-2 %arg{1}
  kak-bundle-plug-rep-opt-2 %arg{1}
  kak-bundle-plug-rep-opt-2 %arg{1}
} -override -hidden
def kak-bundle-plug-rep-opt-16 -params 1 %{
  kak-bundle-plug-rep-opt-4 %arg{1}
  kak-bundle-plug-rep-opt-4 %arg{1}
} -override -hidden
def kak-bundle-plug-rep-opt-64 -params 1 %{
  kak-bundle-plug-rep-opt-8 %arg{1}
  kak-bundle-plug-rep-opt-8 %arg{1}
} -override -hidden
def kak-bundle-plug-rep-opt-128 -params 1 %{
  kak-bundle-plug-rep-opt-64 %arg{1}
  kak-bundle-plug-rep-opt-2 %arg{1}
} -override -hidden
def kak-bundle-plug-rep-opt-256 -params 1 %{
  kak-bundle-plug-rep-opt-16 %arg{1}
  kak-bundle-plug-rep-opt-16 %arg{1}
} -override -hidden
def kak-bundle-plug-rep-opt-1024 -params 1 %{
  kak-bundle-plug-rep-opt-256 %arg{1}
  kak-bundle-plug-rep-opt-4 %arg{1}
} -override -hidden

set global kak_bundle_plug_code_str %{%arg{@};}
def kak-bundle-plug-loop-1  -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-2  -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-4  -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-8 -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-16 -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-32 -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-64 -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-128 -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden
kak-bundle-plug-rep-opt-2 kak_bundle_plug_code_str
def kak-bundle-plug-loop-256 -params .. "%opt{kak_bundle_plug_code_str}" -override -hidden

def kak-bundle-plug-loop-inf -params .. %{
  %arg{@}
  kak-bundle-plug-loop-16 %arg{@}
  kak-bundle-plug-loop-16 kak-bundle-plug-loop-16 %arg{@}
  kak-bundle-plug-loop-16 kak-bundle-plug-loop-16 kak-bundle-plug-loop-16 %arg{@}
  kak-bundle-plug-loop-inf kak-bundle-plug-loop-256 kak-bundle-plug-loop-256 %arg{@}  # will reach recursion limit
  fail %{loop-inf: shouldn't reach}
} -override -hidden

def kak-bundle-plug-nop-0_0 -params 0   %{nop} -override -hidden
def kak-bundle-plug-nop-1_  -params 1.. %{nop} -override -hidden
def kak-bundle-plug-nop-1_1 -params 1   %{nop} -override -hidden

def kak-bundle-plug-shift-1_1 -params 1.. %{
  set         global kak_bundle_plug_args %arg{@}
  set -remove global kak_bundle_plug_args %arg{1}
} -override -hidden
def kak-bundle-plug-shift-1_2 -params 2.. %{
  set         global kak_bundle_plug_args %arg{@}
  set -remove global kak_bundle_plug_args %arg{1} %arg{2}
} -override -hidden
def kak-bundle-plug-shift-1_3 -params 3.. %{
  set         global kak_bundle_plug_args %arg{@}
  set -remove global kak_bundle_plug_args %arg{1} %arg{2} %arg{3}
} -override -hidden
def kak-bundle-plug-shift-1_4 -params 4.. %{
  set         global kak_bundle_plug_args %arg{@}
  set -remove global kak_bundle_plug_args %arg{1} %arg{2} %arg{3} %arg{4}
} -override -hidden

decl -hidden str-list kak_bundle_plug_test_err_slist
def kak-bundle-plug-err-chk -params .. -docstring %{
  If err != arg1, calls %arg{@}
  if err == arg1, calls %arg{@:2}
  E.g. chk fail nop %val{error} ('fail fail' in code): ignore 'fail', or re-raise
  Use with custom def'd fails
  Note: executing empty str-list succeeds; set, but not 'reg' can create emty lists
} %{
  set         global kak_bundle_plug_test_err_slist %arg{@}
  set -remove global kak_bundle_plug_test_err_slist %val{error}
  %opt{kak_bundle_plug_test_err_slist}
} -override -hidden

def kak-bundle-plug-strne -params 2 %{
  set         global kak_bundle_plug_test_slist %arg{1}
  set -remove global kak_bundle_plug_test_slist %arg{2}
  kak-bundle-plug-nop-1   %opt{kak_bundle_plug_test_slist}
} -override -hidden

def kak-bundle-plug-streq -params 2 %{
  set         global kak_bundle_plug_test_slist %arg{1}
  set -remove global kak_bundle_plug_test_slist %arg{2}
  kak-bundle-plug-nop-0_0 %opt{kak_bundle_plug_test_slist}
} -override -hidden

def kak-bundle-plug-strcmp-fail -params .. -override -hidden %{ fail %val{error} }
def kak-bundle-plug-strne-orfail -params 2..3 %{
  try %{ kak-bundle-plug-strne %arg{1} %arg{2} } catch %{ fail "kak-bundle-plug-strcmp-fail%arg{3}" }
} -override -hidden
def kak-bundle-plug-streq-orfail -params 2..3 %{
  try %{ kak-bundle-plug-streq %arg{1} %arg{2} } catch %{ fail "kak-bundle-plug-strcmp-fail%arg{3}" }
} -override -hidden

def kak-bundle-plug-rep-slist-2 -params 1 %{
  eval "set -add global %arg{1} %%opt{%arg{1}}"
} -override -hidden

# trampoline
decl -hidden str-list kak_bundle_plug_trpln
def kak-bundle-plug-trpln-jump -params 0 %{
  %opt{kak_bundle_plug_trpln}
} -override -hidden
def kak-bundle-plug-trpln-land -params .. %{
  set global kak_bundle_plug_trpln %arg{@}
} -override -hidden

def kak-bundle-plug-self-preprocess-short2long -docstring %{short -> long while editing source} %{
  try %{ exec -draft '%s' '@' 'E@-' '<ret>c' 'kak-bundle-plug-' '<esc>' }
  try %{ exec -draft '%s' '@' 'E@_' '<ret>c' 'kak_bundle_plug_' '<esc>' }
} -override -hidden
def kak-bundle-plug-self-preprocess-long2short -docstring %{long -> short while editing source} %{
  try %{ exec -draft '%s' 'kak-bundle-' 'plug-' '<ret>c' 'kak-bundle-plug-' '<esc>' }
  try %{ exec -draft '%s' 'kak_bundle_' 'plug_' '<ret>c' 'kak_bundle_plug_' '<esc>' }
} -override -hidden
def kak-bundle-plug-self-preprocess-def-aliases %{
  alias global :pp> kak-bundle-plug-self-preprocess-short2long
  alias global :pp< kak-bundle-plug-self-preprocess-long2short
} -override -hidden

def kak-bundle-plug-dbg -params .. %{
  echo -debug -quoting kakoune -- %arg{@}
} -override -hidden


# implementation

decl -hidden str-list kak_bundle_plug_cmd
decl -hidden str      kak_bundle_plug_cmd_url
decl -hidden str      kak_bundle_plug_cmd_config
decl -hidden bool     kak_bundle_plug_cmd_load

def kak-bundle-plug-stop -params .. %{
  fail %val{error}
} -override -hidden

def kak-bundle-plug-0 -params .. %{
  kak-bundle-plug-trpln-land kak-bundle-plug-1 %arg{@} plug  # <-- terminator
  try %{
    kak-bundle-plug-loop-inf kak-bundle-plug-trpln-jump
  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-stop }
} -override -hidden

def kak-bundle-plug-1 -params .. %{
  try %{ kak-bundle-plug-nop-1_ %arg{@} } catch %{
    fail kak-bundle-plug-stop
  }  # stop if args exhausted
  set global kak_bundle_plug_cmd_url %arg{1}
  kak-bundle-plug-shift-1_1 %arg{@}
  try %{  # ignore redundant initial plug
    kak-bundle-plug-streq-orfail %arg{1} plug
    kak-bundle-plug-trpln-land kak-bundle-plug-1 %opt{kak_bundle_plug_args}
  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    set global kak_bundle_plug_cmd_load true
    set global kak_bundle_plug_cmd_config ''
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}
  }
} -override -hidden

def kak-bundle-plug-2 -params .. %{
  try %{
    kak-bundle-plug-nop-0_0 %arg{@}
    fail %{kak-bundle-plug: internal error}

  } catch %{
    kak-bundle-plug-streq-orfail plug %arg{1}  # separator / terminator
    kak-bundle-plug-shift-1_1 %arg{@}
    kak-bundle-plug-if "kak-bundle-plug-%opt{kak_bundle_plug_cmd_load}" %{
      set -add global kak_bundle_plug_cmd %opt{kak_bundle_plug_cmd_url} %opt{kak_bundle_plug_cmd_config}
    } %{  # ELSE
      bundle %opt{kak_bundle_plug_cmd_url}
    }
    kak-bundle-plug-trpln-land kak-bundle-plug-1 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail config %arg{1}
    set -add global kak_bundle_plug_cmd_config "
      %arg{2}
    "
    kak-bundle-plug-shift-1_2 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail demand %arg{1}
    kak-bundle-plug-2-defer %arg{@}
    set -add global kak_bundle_plug_cmd_config "
      try %%{ require-module %arg{2} } catch %%{
        echo -debug 'kak-bundle-plug: require-module %arg{2} failed'
      }
    "
    kak-bundle-plug-shift-1_3 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail defer %arg{1}
    kak-bundle-plug-2-defer %arg{@}
    kak-bundle-plug-shift-1_3 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail load-path %arg{1}
    set global kak_bundle_plug_cmd_url "ln -sf ""%arg{2}"" # %arg{2}"  # avoid stray final '"'
    kak-bundle-plug-shift-1_2 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail noload %arg{1}
    set global kak_bundle_plug_cmd_load false
    kak-bundle-plug-shift-1_1 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail branch %arg{1}
    set global kak_bundle_plug_cmd_url "git clone %opt{bundle_git_clone_opts} %opt{bundle_git_shallow_opts} --branch=%arg{2} %opt{kak_bundle_plug_cmd_url}"
    kak-bundle-plug-shift-1_2 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail tag %arg{1}
    set global kak_bundle_plug_cmd_url "git clone %opt{bundle_git_clone_opts} %opt{bundle_git_shallow_opts} --tags --branch=%arg{2} %opt{kak_bundle_plug_cmd_url}"
    kak-bundle-plug-shift-1_2 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail comment %arg{1}
    kak-bundle-plug-shift-1_2 %arg{@}
    kak-bundle-plug-trpln-land kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    fail "kak-bundle-plug-: unknown parameter <%arg{1}>"
  }
} -override -hidden

def kak-bundle-plug-2-defer -params .. %{
  set -add global kak_bundle_plug_cmd_config "
    hook -group kak-bundle-plug global ModuleLoaded %arg{2} %%{%arg{3}}
  "
} -override -hidden
#PP:COPY
#PP:IN
}
#PP:IGNORE
