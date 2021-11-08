eval -- %sh{ set -u
  mydir=${kak_source%/*}; : "${mydir:=/}"; myname=${kak_source##*/};
  compile() {
    printf >&2 '%s\n' "$myname: compiling"
    #cp "$1" "$2"
    local global_rewrite; global_rewrite='my $p=q(@E@);
      s/${p}-/kak-bundle-plug-/g; s/${p}_/kak_bundle_plug_/g;
      s/${p}:-/kak-bundle-plug/g;
    '
    PERL_UNICODE=SDA perl -- "$mydir"/../preproc "$1" "$global_rewrite" >"$2" && [ -s "$2" ] || return 1
  }
  set -- "$kak_source"
  set -- "$1".in "$1".compiled; echo "source %\"$2\""
  if [ -e "$2" ] && [ "$2" -nt "$1" ] && ! [ "$2" -ot "$2" ]; then return 0; fi
  if ! compile "$@"; then
    rm -f "$2"
    echo "fail %{$myname: compiler failure}"
    exit 1
  fi
}; echo -debug %{kak-bundle-plug: compiled version loaded}
