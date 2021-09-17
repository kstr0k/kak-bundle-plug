def kak-bundle-plug -params 1.. -docstring %{
  Partially emulates plug.kak using kak-bundle
  Args: [ {URL|CMD} POST-LOAD plug]..
    POST-LOAD: {
      config CFG |
      {demand|defer} MODNAME POST-REQUIRE |
      load-path PATH
    }
} %{
  set global kak_bundle_plug_cmd
  kak-bundle-plug-0 %arg{@}
  bundle-register-and-load %opt{kak_bundle_plug_cmd}
} -override


## kakscript library

decl -hidden str-list kak_bundle_plug_test_slist
decl -hidden str-list kak_bundle_plug_slist
decl -hidden str-list kak_bundle_plug_code_slist
decl -hidden str      kak_bundle_plug_str

def kak-bundle-plug-nop-0_0 -params 0 %{nop} -override -hidden
def kak-bundle-plug-nop-1_1 -params 1 %{nop} -override -hidden

decl -hidden str-list kak_bundle_plug_args
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

def kak-bundle-plug-fail-with -params 2 %{
  try %arg{2} catch %{ fail %arg{1} }
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
def kak-bundle-plug-strne-orfail -params 2 %{
  try %{ kak-bundle-plug-strne %arg{1} %arg{2} } catch %{ fail kak-bundle-plug-strcmp-fail }
} -override -hidden
def kak-bundle-plug-streq-orfail -params 2 %{
  try %{ kak-bundle-plug-streq %arg{1} %arg{2} } catch %{ fail kak-bundle-plug-strcmp-fail }
} -override -hidden

def kak-bundle-plug-rep-slist-2 -params 1 %{
  eval "set -add global %arg{1} %%opt{%arg{1}}"
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

decl -hidden str-list kak_bundle_plug_next
decl -hidden str-list kak_bundle_plug_cmd
decl -hidden str      kak_bundle_plug_cmd_url
decl -hidden str      kak_bundle_plug_cmd_config

# decrease recursion by repeating code; upto N-1 useless try's at end
set global kak_bundle_plug_code_slist %{
  try %{ kak-bundle-plug-nop-0_0 %opt{kak_bundle_plug_next} } catch %{
    kak-bundle-plug-1 %opt{kak_bundle_plug_next}
  }
}
kak-bundle-plug-rep-slist-2 kak_bundle_plug_code_slist
kak-bundle-plug-rep-slist-2 kak_bundle_plug_code_slist
kak-bundle-plug-rep-slist-2 kak_bundle_plug_code_slist
kak-bundle-plug-rep-slist-2 kak_bundle_plug_code_slist
# to disallow plug with no args: add initial call to ...-1 (no try)
set global kak_bundle_plug_code_slist %{
  set global kak_bundle_plug_next %arg{@}
} %opt{kak_bundle_plug_code_slist} %{
  try %{ kak-bundle-plug-nop-0_0 %opt{kak_bundle_plug_next} } catch %{
    kak-bundle-plug-0 %opt{kak_bundle_plug_next}
  }
}
def kak-bundle-plug-0 -params 1.. "%opt{kak_bundle_plug_code_slist}" -override -hidden

def kak-bundle-plug-1 -params 1.. %{
  set global kak_bundle_plug_cmd_url %arg{1}
  set global kak_bundle_plug_cmd_config ''
  set global kak_bundle_plug_next
  kak-bundle-plug-shift-1_1 %arg{@}
  kak-bundle-plug-2 %opt{kak_bundle_plug_args}
  set -add global kak_bundle_plug_cmd %opt{kak_bundle_plug_cmd_url} %opt{kak_bundle_plug_cmd_config}
} -override -hidden

def kak-bundle-plug-2 -params .. %{
  try %{ kak-bundle-plug-nop-0_0 %arg{@} } catch %{
    kak-bundle-plug-streq-orfail plug %arg{1}
    kak-bundle-plug-shift-1_1 %arg{@}
    set global kak_bundle_plug_next %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail config %arg{1}
    set -add global kak_bundle_plug_cmd_config "
      %arg{2}
    "
    kak-bundle-plug-shift-1_2 %arg{@}
    kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail demand %arg{1}
    kak-bundle-plug-2-defer %arg{@}
    set -add global kak_bundle_plug_cmd_config "
      try %%{ require-module %arg{2} } catch %%{
        echo -debug 'kak-bundle-plug: require-module %arg{2} failed'
      }
    "
    kak-bundle-plug-shift-1_3 %arg{@}
    kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail defer %arg{1}
    kak-bundle-plug-2-defer %arg{@}
    kak-bundle-plug-shift-1_3 %arg{@}
    kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    kak-bundle-plug-streq-orfail load-path %arg{1}
    set global kak_bundle_plug_cmd_url "ln -sf ""%arg{2}"" # %arg{2}"  # avoid stray final '"'
    kak-bundle-plug-shift-1_2 %arg{@}
    kak-bundle-plug-2 %opt{kak_bundle_plug_args}

  } catch %{ kak-bundle-plug-err-chk kak-bundle-plug-strcmp-fail
    fail "kak-bundle-plug-: unknown parameter <%arg{1}>"
  }
} -override -hidden

def kak-bundle-plug-2-defer -params .. %{
  set -add global kak_bundle_plug_cmd_config "
    hook -group kak-bundle-plug global ModuleLoaded %arg{2} %%{%arg{3}}
  "
} -override -hidden
