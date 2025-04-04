# MRM using pmtiles

## Get started on SSPCloud
- [Using VSCode and Python](https://datalab.sspcloud.fr/launcher/ide/vscode-python?name=mrm-pmtiles&init.personalInit=%C2%ABhttps%3A%2F%2Fraw.githubusercontent.com%2FGaspi%2Fmrm-pmtiles%2Frefs%2Fheads%2Fmain%2Finit-scripts%2Fvscode.sh%C2%BB)

## Install the project
```sh
pip install -e .
```


## Generate pmtiles from ARCEP data

Download and unzip `geopackage` files:
```sh
cd data
METRO_DATA_FILES=$(curl https://data.arcep.fr/mobile/couvertures_theoriques/last/Metropole/00_Metropole/index.html 2> /dev/null | grep '"[^"]*\.7z"' -oh)
for URL in ${METRO_DATA_FILES}
do
    FILE=${URL//\"}
    wget https://data.arcep.fr/mobile/couvertures_theoriques/last/Metropole/00_Metropole/$FILE -O $FILE
    7z -y x $FILE
    rm $FILE
done
```

`geopackage` files can be processed into the `pmtiles` tiled format using [`tippecanoe`](https://github.com/mapbox/tippecanoe):
```sh
ogr2ogr -f GeoJSONSeq /vsistdout/ 2024_T3_couv_Metropole_BOUY_4G_data.gpkg | tippecanoe -z14 -P -S 2 -pS -ac -ah -ao -l BOUY -o BOUY.pmtiles
ogr2ogr -f GeoJSONSeq /vsistdout/ 2024_T3_couv_Metropole_FREE_4G_data.gpkg | tippecanoe -z14 -P -S 2 -pS -ac -ah -ao -l FREE -o FREE.pmtiles
ogr2ogr -f GeoJSONSeq /vsistdout/ 2024_T3_couv_Metropole_OF_4G_data.gpkg   | tippecanoe -z14 -P -S 2 -pS -ac -ah -ao -l OF   -o   OF.pmtiles
ogr2ogr -f GeoJSONSeq /vsistdout/ 2024_T3_couv_Metropole_SFR0_4G_data.gpkg | tippecanoe -z14 -P -S 2 -pS -ac -ah -ao -l SFR0 -o SFR0.pmtiles
```

Several `pmtiles` files can be joined in a single file in which datasets are represented as "layers":
```sh
tile-join -pk -o 2024_T3_couv_Metropole_4G_data.pmtiles BOUY.pmtiles FREE.pmtiles OF.pmtiles SFR0.pmtiles
rm BOUY.pmtiles FREE.pmtiles OF.pmtiles SFR0.pmtiles
```
NOTE: While packing layers together is convenient for visualisation, it may not be the best option, for instance to embed the tiled data in a website.


```sh
mc cp 2024_T3_couv_Metropole_4G_data.pmtiles s3/gferey/diffusion/pmtiles/2024_T3_couv_Metropole_4G_data.pmtiles
mc anonymous set download s3/gferey/diffusion/pmtiles/2024_T3_couv_Metropole_4G_data.pmtiles
```
