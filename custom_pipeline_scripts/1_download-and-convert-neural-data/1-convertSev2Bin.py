# get arguments
import sys

store=sys.argv[1]
chStart=int(sys.argv[2])
chEnd=int(sys.argv[3])
channels=list(range(chStart,chEnd+1))

# create bin file
from tdt import read_block

if False:
	read_block('.', store=store, channel=channels, export='interlaced')
	# NOTE: this automatically exports at int16, becuase it detects it was saved as that.
	# No need to rescale, since it was saved in microvolts.

	# Save metadata about the num samples in this bin file. Useful for splitting across sessions to match to other data.
else:
	# LT (6/25/24) - to store metadata for each binary file (n samples).
	data = read_block('.', store=store, channel=channels, export='interlaced', return_data_even_if_export=True)

	def writeStringsToFile(fname, stringlist, silent=True, append=False):
	    """ atuoamtically overwrite
	    fname, add .txt if you want.
	    PARAMS:
	    - append, bool, if True, then doesnt overwrite.
	    """
	    if append:
	        mode = "a"
	    else:
	        mode = "w"
	    with open(fname, mode) as f:
	        for s in stringlist:
	            if not silent:
	                print(s)
	            f.write(f"{s}\n")

	def writeDictToTxt(dictdat, path):
	    """ Write each key:val of dict as as new line in text file
	    f"{key} : {val}"
	    PARAMS:
	    - path, imcludes extension.
	    """
	    list_s = []
	    for key, val in dictdat.items():
	        list_s.append(f"{key} : {val}")
	    writeStringsToFile(path, list_s)

	metadat = {"data_shape":data[store]["data"].shape, "channels":data[store]["channels"]}
	writeDictToTxt(metadat, f"metadat-{store}-{chStart}-{chEnd}.txt")