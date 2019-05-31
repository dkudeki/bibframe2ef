import sys, os, json, subprocess, time, datetime
from datetime import timedelta
from multiprocessing import Pool

def fillIncompleteResults(output_folder):
	incomplete_folder = output_folder + 'incomplete/'
	complete_folder = output_folder + 'complete/'

	with open(output_folder + 'dicts/instance.json','r') as instance_readfile:
		instances = json.load(instance_readfile)

	with open(output_folder + 'dicts/meta.json','r') as meta_readfile:
		meta = json.load(meta_readfile)

	with open(output_folder + 'reports/missing_metadata.txt','w') as err_file:
		for root, dirs, files in os.walk(incomplete_folder):
			for f in files:
				print(incomplete_folder + f)
				with open(incomplete_folder + f,'r') as readfile:
					ef = json.load(readfile)
					if type(ef['metadata']['identifier']) == dict and ef['metadata']['identifier']['propertyID'] == 'oclc':
						instance_id = ef['metadata']['identifier']['value']
					else:
						for ids in ef['metadata']['identifier']:
							if ids['propertyID'] == 'oclc':
								instance_id = ids['value']

					work_id = instances[instance_id]
					try:
						work_dict = meta[str(work_id)]
						print(ef['metadata']['id'])
						for key in work_dict.keys():
							if key not in ef['metadata'] or key == 'title':
								ef['metadata'][key] = work_dict[key]

						with open(complete_folder + f,'w') as writefile:
							json.dump(ef,writefile,indent=4)
					except:
						err_file.write(work_id + ' ' + f + '\n')

				if os.path.exists(complete_folder + f):
					os.remove(incomplete_folder + f)

if __name__ == "__main__":
	fillIncompleteResults(sys.argv[1])