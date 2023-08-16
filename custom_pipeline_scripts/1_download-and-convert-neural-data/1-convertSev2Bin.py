# get arguments
import sys

store=sys.argv[1]
chStart=int(sys.argv[2])
chEnd=int(sys.argv[3])
channels=list(range(chStart,chEnd+1))

# create bin file
from tdt import read_block

read_block('.', store=store, channel=channels, export='interlaced')
# NOTE: this automatically exports at int16, becuase it detects it was saved as that.
# No need to rescale, since it was saved in microvolts.

