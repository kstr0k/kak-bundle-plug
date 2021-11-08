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
  set -- "$1".in "$1".compiled; echo "source %\"$2\""
  if [ -e "$2" ] && [ "$2" -nt "$1" ] && ! [ "$2" -ot "$2" ]; then :
  else compile "$@"
  fi
}; echo -debug %{kak-bundle-plug: compiled version loaded}
