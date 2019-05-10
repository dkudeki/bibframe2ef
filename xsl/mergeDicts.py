import sys, os, json, time, datetime
from datetime import timedelta

def mergeDicts(output_folder):
	dict_folder = output_folder + 'dicts/'

	master_instance = {}
	master_meta = {}

	start_time = datetime.datetime.now().time()

	for root, dirs, files in os.walk(dict_folder):
		for f in files:
			with open(dict_folder + f,'r') as readfile:
				if f[-14:-5] == '_instance':
					master_instance.update(json.load(readfile))
				else:
					master_meta.update(json.load(readfile))

	with open(dict_folder + 'instance.json','w') as write_file:
		json.dump(master_instance,write_file)
	with open(dict_folder + 'meta.json','w') as write_file:
		json.dump(master_meta,write_file)

	end_time = datetime.datetime.now().time()
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

if __name__ == "__main__":
	mergeDicts(sys.argv[1])