# cso_contextual
contextual layers for cso dashboard

<b>country contents: </b>

Each country contains a megapixels geojson file, a "whole_country_rasters" folder and a "masked_rasters" folder. The masked rasters show only the data overlapping with the megapixels and the whole_country_rasters folder contains data for the entire country. The megapixels correspond to the hotspots identified by the CSO climate security spatial analysis. 

<b>Individual country notes: </b>

GTM: missing dependency ratio <br>
PHL: missing FSL and LHZ <br>
SDN: missing AWE and RWI <br>
ZMB: missing FSL and LHZ <br>

<b>notes on datasets: </b>

All data is sourced from CGIAR-CIAT's CSO data dictionary, with the exception of two datasets- LHZ (livelihood zones) and FSL (food security)- both of which are sourced from FEWSNET (https://fews.net/fews-data/335). The LHZ data is a simple rasterization of the latest LHZ shapefiles available for each country. The FSL data is a reflection of FEWSNET's most recently available assessment (in this case, Feb 2022). 
