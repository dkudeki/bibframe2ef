import sys, os, json, time, datetime
from datetime import timedelta

def mergeDicts(output_folder):
	dict_folder = output_folder + 'dicts/'

	master_meta = {}

	start_time = datetime.datetime.now().time()

	for root, dirs, files in os.walk(dict_folder):

		for f in files:
			if f[-10:-5] == '_meta':
				print(f)
				with open(dict_folder + f,'r') as readfile:
					imported = json.load(readfile)
					for instance in imported:
						if instance not in master_meta:
							master_meta[instance] = imported[instance]
						else:
							for field in imported[instance]:
								if field not in master_meta[instance]:
									master_meta[instance][field] = imported[instance][field]

	with open(dict_folder + 'meta.json','w') as write_file:
		json.dump(master_meta,write_file)

	end_time = datetime.datetime.now().time()
	print("MERGE DICTS:")
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

if __name__ == "__main__":
	mergeDicts(sys.argv[1])