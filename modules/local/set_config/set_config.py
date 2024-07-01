import sys

gtf = sys.args[1]
READS = sys.args[2]



datasetnames= [".".join(read.name.split('.')[:-1]) for read in READS]

for read, name in zip(gtf, datasetnames):
            with open("oxford_config.tab", 'a+') as config:
                config.write("%s\t%s\n" % (name, read))