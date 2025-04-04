
#!/bin/sh

# You may use this initialization script to easily setup an Onyxia "vscode-python" service
# https://datalab.sspcloud.fr/launcher/ide/vscode-python?name=mrm-pmtiles&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2FGaspi%2Fmrm-pmtiles%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Fvscode.sh%C2%BB

sudo apt update -y
sudo apt install -y tree libsqlite3-dev libz-dev p7zip-full

# Clone project
cd ~/work/
git clone https://github.com/Gaspi/mrm-pmtiles.git
cd ~/work/mrm-pmtiles/

# Install project (requirements and main package)
#pip install -e .

# Replace default flake8 linter with project-preconfigured ruff
code-server --uninstall-extension ms-python.flake8
code-server --install-extension charliermarsh.ruff

# Install the mypy type checking extension and run type checking
pip install mypy
#yes | mypy --install-types .
code-server --install-extension ms-python.mypy-type-checker

# Install and setup pre-commit
pip install pre-commit
#pre-commit install
#pre-commit run --all-files

mkdir data/
cd data/

# Install Tippecanoe
git clone https://github.com/felt/tippecanoe.git
cd tippecanoe
make -j
sudo make install
cd ..

# Install pmtiles
mkdir pmtiles
cd pmtiles
wget https://github.com/protomaps/go-pmtiles/releases/download/v1.26.1/go-pmtiles_1.26.1_Linux_x86_64.tar.gz
tar -zxvf go-pmtiles_1.26.1_Linux_x86_64.tar.gz
sudo cp pmtiles /usr/local/bin/
cd ..

# PreDownload datafiles
curl https://data.arcep.fr/mobile/couvertures_theoriques/last/Metropole/00_Metropole/index.html 2> /dev/null | grep '"[^"]*\.7z"' -oh | xargs -i{} wget https://data.arcep.fr/mobile/couvertures_theoriques/last/Metropole/00_Metropole/{}
ls ./*.7z | xargs -I{} 7z -y x {}
rm ./*.7z
