#PP:IN
eval -- %sh{ set -u
  mydir=${kak_source%/*}; : "${mydir:=/}"
  compile() {
    echo >&2 'kak-bundle-plug: compiling'
    #cp "$1" "$2"
    local global_rewrite; global_rewrite='my $p=q(@E@);
      s/${p}-/kak-bundle-plug-/g; s/${p}_/kak_bundle_plug_/g;
      s/${p}:-/kak-bundle-plug/g;
    '
    PERL_UNICODE=SDA exec perl -- "$mydir"/../preproc "$1" "$global_rewrite" >"$2"
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
#PP:IGNORE#PP:IN

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

decl -hidden str      @E@_str
decl -hidden str-list @E@_slist
decl -hidden str-list @E@_test_slist
decl -hidden str-list @E@_code_slist
decl -hidden str      @E@_code_str
decl -hidden str-list @E@_args

def @E@-true  -params 2 %{ eval %arg{1} } -override -hidden
def @E@-false -params 2 %{ eval %arg{2} } -override -hidden
def @E@-if    -params 3 %{ %arg{@} } -override -hidden

def @E@-rep-opt-2 -params 1 %{
  eval "set -add global %arg{1} %%opt{%arg{1}}"
} -override -hidden
def @E@-rep-opt-4 -params 1 %{
  @E@-rep-opt-2 %arg{1}
  @E@-rep-opt-2 %arg{1}
} -override -hidden
def @E@-rep-opt-8 -params 1 %{
  @E@-rep-opt-2 %arg{1}
  @E@-rep-opt-2 %arg{1}
  @E@-rep-opt-2 %arg{1}
} -override -hidden
def @E@-rep-opt-16 -params 1 %{
  @E@-rep-opt-4 %arg{1}
  @E@-rep-opt-4 %arg{1}
} -override -hidden
def @E@-rep-opt-64 -params 1 %{
  @E@-rep-opt-8 %arg{1}
  @E@-rep-opt-8 %arg{1}
} -override -hidden
def @E@-rep-opt-128 -params 1 %{
  @E@-rep-opt-64 %arg{1}
  @E@-rep-opt-2 %arg{1}
} -override -hidden
def @E@-rep-opt-256 -params 1 %{
  @E@-rep-opt-16 %arg{1}
  @E@-rep-opt-16 %arg{1}
} -override -hidden
def @E@-rep-opt-1024 -params 1 %{
  @E@-rep-opt-256 %arg{1}
  @E@-rep-opt-4 %arg{1}
} -override -hidden

set global @E@_code_str %{%arg{@};}
def @E@-loop-1  -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-2  -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-4  -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-8 -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-16 -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-32 -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-64 -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-128 -params .. "%opt{@E@_code_str}" -override -hidden
@E@-rep-opt-2 @E@_code_str
def @E@-loop-256 -params .. "%opt{@E@_code_str}" -override -hidden

def @E@-loop-inf -params .. %{
  %arg{@}
  @E@-loop-16 %arg{@}
  @E@-loop-16 @E@-loop-16 %arg{@}
  @E@-loop-16 @E@-loop-16 @E@-loop-16 %arg{@}
  @E@-loop-inf @E@-loop-256 @E@-loop-256 %arg{@}  # will reach recursion limit
  fail %{loop-inf: shouldn't reach}
} -override -hidden

def @E@-nop-0_0 -params 0   %{nop} -override -hidden
def @E@-nop-1_  -params 1.. %{nop} -override -hidden
def @E@-nop-1_1 -params 1   %{nop} -override -hidden

def @E@-shift-1_1 -params 1.. %{
  set         global @E@_args %arg{@}
  set -remove global @E@_args %arg{1}
} -override -hidden
def @E@-shift-1_2 -params 2.. %{
  set         global @E@_args %arg{@}
  set -remove global @E@_args %arg{1} %arg{2}
} -override -hidden
def @E@-shift-1_3 -params 3.. %{
  set         global @E@_args %arg{@}
  set -remove global @E@_args %arg{1} %arg{2} %arg{3}
} -override -hidden
def @E@-shift-1_4 -params 4.. %{
  set         global @E@_args %arg{@}
  set -remove global @E@_args %arg{1} %arg{2} %arg{3} %arg{4}
} -override -hidden

decl -hidden str-list @E@_test_err_slist
def @E@-err-chk -params .. -docstring %{
  If err != arg1, calls %arg{@}
  if err == arg1, calls %arg{@:2}
  E.g. chk fail nop %val{error} ('fail fail' in code): ignore 'fail', or re-raise
  Use with custom def'd fails
  Note: executing empty str-list succeeds; set, but not 'reg' can create emty lists
} %{
  set         global @E@_test_err_slist %arg{@}
  set -remove global @E@_test_err_slist %val{error}
  %opt{@E@_test_err_slist}
} -override -hidden

def @E@-strne -params 2 %{
  set         global @E@_test_slist %arg{1}
  set -remove global @E@_test_slist %arg{2}
  @E@-nop-1   %opt{@E@_test_slist}
} -override -hidden

def @E@-streq -params 2 %{
  set         global @E@_test_slist %arg{1}
  set -remove global @E@_test_slist %arg{2}
  @E@-nop-0_0 %opt{@E@_test_slist}
} -override -hidden

def @E@-strcmp-fail -params .. -override -hidden %{ fail %val{error} }
def @E@-strne-orfail -params 2..3 %{
  try %{ @E@-strne %arg{1} %arg{2} } catch %{ fail "@E@-strcmp-fail%arg{3}" }
} -override -hidden
def @E@-streq-orfail -params 2..3 %{
  try %{ @E@-streq %arg{1} %arg{2} } catch %{ fail "@E@-strcmp-fail%arg{3}" }
} -override -hidden

def @E@-rep-slist-2 -params 1 %{
  eval "set -add global %arg{1} %%opt{%arg{1}}"
} -override -hidden

# trampoline
decl -hidden str-list @E@_trpln
def @E@-trpln-jump -params 0 %{
  %opt{@E@_trpln}
} -override -hidden
def @E@-trpln-land -params .. %{
  set global @E@_trpln %arg{@}
} -override -hidden

def @E@-self-preprocess-short2long -docstring %{short -> long while editing source} %{
  try %{ exec -draft '%s' '@' 'E@-' '<ret>c' '@E@-' '<esc>' }
  try %{ exec -draft '%s' '@' 'E@_' '<ret>c' '@E@_' '<esc>' }
} -override -hidden
def @E@-self-preprocess-long2short -docstring %{long -> short while editing source} %{
  try %{ exec -draft '%s' 'kak-bundle-' 'plug-' '<ret>c' '@E@-' '<esc>' }
  try %{ exec -draft '%s' 'kak_bundle_' 'plug_' '<ret>c' '@E@_' '<esc>' }
} -override -hidden
def @E@-self-preprocess-def-aliases %{
  alias global :pp> @E@-self-preprocess-short2long
  alias global :pp< @E@-self-preprocess-long2short
} -override -hidden

def @E@-dbg -params .. %{
  echo -debug -quoting kakoune -- %arg{@}
} -override -hidden


# implementation

decl -hidden str-list @E@_cmd
decl -hidden str      @E@_cmd_url
decl -hidden str      @E@_cmd_config
decl -hidden bool     @E@_cmd_load

def @E@-stop -params .. %{
  fail %val{error}
} -override -hidden

def @E@-0 -params .. %{
  @E@-trpln-land @E@-1 %arg{@} plug  # <-- terminator
  try %{
    @E@-loop-inf @E@-trpln-jump
  } catch %{ @E@-err-chk @E@-stop }
} -override -hidden

def @E@-1 -params .. %{
  try %{ @E@-nop-1_ %arg{@} } catch %{
    fail @E@-stop
  }  # stop if args exhausted
  set global @E@_cmd_url %arg{1}
  @E@-shift-1_1 %arg{@}
  try %{  # ignore redundant initial plug
    @E@-streq-orfail %arg{1} plug
    @E@-trpln-land @E@-1 %opt{@E@_args}
  } catch %{ @E@-err-chk @E@-strcmp-fail
    set global @E@_cmd_load true
    set global @E@_cmd_config ''
    @E@-trpln-land @E@-2 %opt{@E@_args}
  }
} -override -hidden

def @E@-2 -params .. %{
  try %{
    @E@-nop-0_0 %arg{@}
    fail %{kak-bundle-plug: internal error}

  } catch %{
    @E@-streq-orfail plug %arg{1}  # separator / terminator
    @E@-shift-1_1 %arg{@}
    @E@-if "@E@-%opt{@E@_cmd_load}" %{
      set -add global @E@_cmd %opt{@E@_cmd_url} %opt{@E@_cmd_config}
    } %{  # ELSE
      bundle %opt{@E@_cmd_url}
    }
    @E@-trpln-land @E@-1 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail config %arg{1}
    set -add global @E@_cmd_config "
      %arg{2}
    "
    @E@-shift-1_2 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail demand %arg{1}
    @E@-2-defer %arg{@}
    set -add global @E@_cmd_config "
      try %%{ require-module %arg{2} } catch %%{
        echo -debug 'kak-bundle-plug: require-module %arg{2} failed'
      }
    "
    @E@-shift-1_3 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail defer %arg{1}
    @E@-2-defer %arg{@}
    @E@-shift-1_3 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail load-path %arg{1}
    set global @E@_cmd_url "ln -sf ""%arg{2}"" # %arg{2}"  # avoid stray final '"'
    @E@-shift-1_2 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail noload %arg{1}
    set global @E@_cmd_load false
    @E@-shift-1_1 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail branch %arg{1}
    set global @E@_cmd_url "git clone %opt{bundle_git_clone_opts} %opt{bundle_git_shallow_opts} --branch=%arg{2} %opt{@E@_cmd_url}"
    @E@-shift-1_2 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail tag %arg{1}
    set global @E@_cmd_url "git clone %opt{bundle_git_clone_opts} %opt{bundle_git_shallow_opts} --tags --branch=%arg{2} %opt{@E@_cmd_url}"
    @E@-shift-1_2 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    @E@-streq-orfail comment %arg{1}
    @E@-shift-1_2 %arg{@}
    @E@-trpln-land @E@-2 %opt{@E@_args}

  } catch %{ @E@-err-chk @E@-strcmp-fail
    fail "@E@-: unknown parameter <%arg{1}>"
  }
} -override -hidden

def @E@-2-defer -params .. %{
  set -add global @E@_cmd_config "
    hook -group kak-bundle-plug global ModuleLoaded %arg{2} %%{%arg{3}}
  "
} -override -hidden
#PP:COPY#PP:IN
}
#PP:IGNORE
