import json, sys, os
from multiprocessing import Pool
from itertools import repeat
from functools import wraps

def unpack(func):
	@wraps(func)
	def wrapper(arg_tuple):
		return func(*arg_tuple)
	return wrapper

def addFieldToJSONLD(last_update_date,htid,output_folder):
	filename = output_folder + '/' + htid[:htid.find('.')] + htid.replace('/','=').replace(':','+') + '.json'
	with open(filename,'r') as f:
		data = json.load(f)

	data.update({'lastRightsUpdateDate': last_update_date})

	with open(filename,'w') as outfile:
		json.dump(data,outfile)

def processMARCJSON(record,output_folder):
	marc_record = json.loads(record)
	for field in marc_record['fields']:
		if '974' in field:
			for subfield in field['974']['subfields']:
				if 'u' in subfield:
					htid = subfield['u']

				if 'd' in subfield:
					date_change = subfield['d']

	addFieldToJSONLD(date_change,htid,output_folder)

@unpack
def processJSONLFile(file_name,output_folder):
	with open(file_name,'r') as readfile:
		recrods = readfile.readlines()
		for r in records:
			processMARCJSON(r,output_folder)

def addLastUpdateDates(input_folder,output_folder,core_count):
	p = Pool(core_count)

	for root, dirs, files in os.walk(input_folder):
		for f in files:
			p.map(processJSONLFile,iterable=zip(f,repeat(output_folder)))

if __name__ == "__main__":
	addLastUpdateDates(sys.argv[1],sys.argv[2],sys.argv[3])