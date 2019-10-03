import sys, os, subprocess, time, datetime
from datetime import timedelta
from multiprocessing import Pool
from itertools import repeat
from functools import wraps

def unpack(func):
	@wraps(func)
	def wrapper(arg_tuple):
		return func(*arg_tuple)
	return wrapper

@unpack
def validate(file,output_folder):
	bashCommand = 'ajv validate -s ../schemas/EF-Schema/ef_2_20_schema.json -d ' + output_folder + 'complete/' + file
	with open(output_folder + 'reports/validation_error.txt','a') as err_output:
		subprocess.call(bashCommand.split(), stderr=err_output)

def validateEFMetadata(output_folder,core_count):
	json_folder = output_folder + 'complete'
	p = Pool(core_count)

	start_time = datetime.datetime.now().time()
	for root, dirs, files in os.walk(json_folder):
		p.map(validate,iterable=zip(files,repeat(output_folder)))

	end_time = datetime.datetime.now().time()
	print("VALIDATE RESULTS:")
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

if __name__ == "__main__":
	validateEFMetadata(sys.argv[1],int(sys.argv[2]))