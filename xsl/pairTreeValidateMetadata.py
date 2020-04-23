import sys, os, json, subprocess, time, datetime, bz2, jsonschema
from datetime import timedelta
from multiprocessing import Pool
from itertools import repeat
from functools import wraps
from pairtree import *

#def unpack(func):
#	@wraps(func)
#	def wrapper(arg_tuple):
#		return func(*arg_tuple)
#	return wrapper

#@unpack
def validate(root,file,schema,output_folder):
#	bashCommand = 'ajv validate -s ../schemas/EF-Schema/ef_2_20_schema.json -d ' + output_folder + file
	print(root + '/' + file)
	with bz2.open(root + '/' + file,'r') as json_file:
		data = json.load(json_file)
#		print(data)
		results = jsonschema.validate(instance=data,schema=schema)
		print(results)



def readPairTree(input_folder,output_folder,core_count):
	with open('../schemas/EF-Schema/ef_3_0_schema.json','r') as schema_file:
		schema = json.load(schema_file)

	p = Pool(core_count)

	start_time = datetime.datetime.now().time()
	for root, dirs, files in os.walk(input_folder):
		p.starmap(validate,iterable=zip(repeat(root),[f for f in files if len(f) > 0 and f[-4:] == '.bz2'],repeat(schema),repeat(output_folder)))
#		if len(files) > 0:
#			print(root + '/' + files[0])
#
#			with bz2.open(root + '/' + files[0],'r') as json_file:
#				data = json.load(json_file)
#				
#			sys.exit()

	end_time = datetime.datetime.now().time()
	print("VALIDATE RESULTS:")
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

if __name__ == "__main__":
	readPairTree(sys.argv[1],sys.argv[2],int(sys.argv[3]))