rm -rf dist
./node_modules/.bin/gulp
cd dist
git init
git add -A
git commit -m 'Auto deploy to github-pages'
git push -f git@github.com:intellilab/mine.git master:gh-pages
