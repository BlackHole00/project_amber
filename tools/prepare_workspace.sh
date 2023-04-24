cd ..

rm build/*

rm  ./run.bat
rm  ./run.sh
rm  ./build.bat
rm  ./build.sh
rm  ./ols.json
rm  ./.vscode/launch.json
rm  ./.vscode/tasks.json

cp ./.vscode/macos_default/launch.json ./.vscode/launch.json
cp ./.vscode/macos_default/tasks.json ./.vscode/tasks.json
cp ./.vscode/macos_default/ols.json ./ols.json
cp ./.vscode/macos_default/run.sh ./run.sh
cp ./.vscode/macos_default/build.sh ./build.sh

cd tools