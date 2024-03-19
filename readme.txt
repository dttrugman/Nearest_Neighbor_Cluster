This program contains Matlab programs written by the late Ilya Zaliapian that can be used for the nearest-neighbor cluster analysis. You only need to
work with the program eq_cluster.m, all the other programs should be placed on the Matlab working path.

The program eq_cluster.m works with a text catalog in column-wise numeric format (if you have any text columns,
please remove them prior to the analysis, or revise the input part of the code). You will need to specify the 
catalog directory and format inside eq_cluster.m -- see lines 100-115 and 122-132 and the related comments.

For example, the attached program is set up to work with the Nevada SeismoLab catalog "NSL_catalog_col.txt"
(which is also attached). Please start by running the eq_cluster.m with no changes (just edit the catalog directory in line 101) to make sure it works on your side.

The program inputs and outputs are described in the eq_cluster.m help.
In addition, the program creates an output file "catalog_out.txt", which is the most useful if you simply need to identify
aftershocks/mainshocks/clusters. It has the following format:

# | year | month | day | hour | min | sec | lat | lon | mag | type | P1 | P2

Here
type = 2 for mainshocks
type = 1 for aftershocks
type =-1 for foreshocks

P1 is the index of event's parent (nearest-neighbor)
P2 is the index of event's mainshock (self for mainshocks)

Comments:
1) This version works with epicenters, depth is ignored. If you prefer to work with hypocenters, in the program
"bp.m" replace the line
d=latlonkm([Lat(i) Lon(i)],[Lat(I) Lon(I)]);
with
d=latlonkm([Lat(i) Lon(i) depth(i)],[Lat(I) Lon(I) depth(I)]);

2) This technique was developed for cluster identification. It may produce reasonable declustering results, but
one should be careful. When working with large events, the declustering may leave visible holes after mainshocks.
An improved declustering technique, which avoids this problem is described here:
https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1029/2018JB017120

