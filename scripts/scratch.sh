
# scratch

 # return 0

git clone --mirror 'https://codeberg.org/forgejo/forgejo.git' && pushd forgejo.git && git repack -a -d -f
popd
archive_folder forgejo.git